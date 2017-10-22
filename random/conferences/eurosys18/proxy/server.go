package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"flag"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"strings"

	"github.com/docker/machine/libmachine/log"
	eurosys18 "github.com/jerryz920/utils/random/conferences/eurosys18"
	kvstore "github.com/jerryz920/utils/random/conferences/eurosys18/kvstore"
	"github.com/sirupsen/logrus"
)

type Principal struct {
	Name    string
	ImageID string
	IP      string
	PortMin int
	PortMax int
}

func SerializePrincipal(p *Principal) (string, error) {
	buf := bytes.Buffer{}
	encoder := json.NewEncoder(&buf)
	if err := encoder.Encode(p); err != nil {
		logrus.Debugf("error encoding principal: %v", *p)
		return "", err
	}
	return buf.String(), nil
}

func ParsePrincipal(s string) (*Principal, error) {
	buf := bytes.NewBufferString(s)
	decoder := json.NewDecoder(buf)
	var p Principal
	if err := decoder.Decode(&p); err != nil {
		logrus.Debugf("error decoding principal: %s", s)
		return nil, nil
	}
	return &p, nil
}

type MetadataRequest struct {
	Principal   string
	OtherValues []string
}

type PrincipalResponse struct {
	Message string
}

var (
	ipRangeMatch *regexp.Regexp = regexp.MustCompile(`(\d+\.\d+\.\d+\.\d+):(\d+)-(\d+)`)
	ipPortMatch  *regexp.Regexp = regexp.MustCompile(`(\d+\.\d+\.\d+\.\d+):(\d+)`)
	pidMatch     *regexp.Regexp = regexp.MustCompile(`\['([-a-zA-Z0-9]+)'\]`)
	pStore       map[string]*Principal
)

func ParseIP(msg string) (string, int, int, int) {
	if matches := ipRangeMatch.FindStringSubmatch(msg); len(matches) != 4 {
		log.Errorf("not valid principal ip-port range: %s", msg)
		return "", 0, 0, http.StatusBadRequest
	} else {
		var p1, p2 int64
		var err error
		if p1, err = strconv.ParseInt(matches[2], 10, 32); err != nil {
			log.Errorf("error parsing port min: %v", err)
			return "", 0, 0, http.StatusBadRequest
		}
		if p2, err = strconv.ParseInt(matches[3], 10, 32); err != nil {
			log.Errorf("error parsing port max: %v", err)
			return "", 0, 0, http.StatusBadRequest
		}
		return matches[1], int(p1), int(p2), http.StatusOK
	}
}

func SetCommonHeader(w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json")
}

func ReadRequest(r *http.Request) (*MetadataRequest, []byte, int) {
	data, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Errorf("error reading the body %v\n", err)
		return nil, nil, http.StatusBadRequest
	}
	buf := bytes.NewBuffer(data)
	d := json.NewDecoder(buf)
	mr := MetadataRequest{}
	if err := d.Decode(&mr); err != nil {
		log.Errorf("error decoding the body %v\n", err)
		return nil, nil, http.StatusBadRequest
	} else {
		return &mr, data, http.StatusOK
	}
}

func GetPrincipalID(resp *http.Response) (string, error) {
	if resp.StatusCode != http.StatusOK {
		logrus.Debugf("error getting response %v\n", resp.StatusCode)
		return "", errors.New("error state " + resp.Status)
	}
	decoder := json.NewDecoder(resp.Body)
	pr := PrincipalResponse{}

	if err := decoder.Decode(&pr); err != nil {
		logrus.Debugf("error in decoding %v\n", err)
		return "", err
	}
	/// message is in ['<ID>'] form
	var matches []string
	if matches = pidMatch.FindStringSubmatch(pr.Message); len(matches) != 2 {
		logrus.Debugf("error finding PID: %v", pr.Message)
		return "", errors.New("error finding pid in response")
	}
	return matches[1], nil
}

type MetadataProxy struct {
	client *http.Client
	pmap   *Pmap
	store  eurosys18.Store
	addr   string
}

func (c *MetadataProxy) getUrl(api string) string {
	addr := ""
	if !strings.HasSuffix(c.addr, "/") {
		addr += c.addr + "/"
	}
	if !strings.HasPrefix(c.addr, "http://") {
		addr = "http://" + addr
	}
	if strings.HasPrefix(api, "/") {
		api = api[1:]
	}
	return addr + api
}

func (c *MetadataProxy) postInstanceSet(w http.ResponseWriter, r *http.Request) {
	m, data, status := ReadRequest(r)
	SetCommonHeader(w)
	if status != http.StatusOK {
		logrus.Debug("error reading request: ", status)
		return
	}

	ip, p1, p2, status := ParseIP(m.OtherValues[3])
	if status != http.StatusOK {
		logrus.Debug("error parsing the IP address: ", status)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Error parsing the IP address"))
		return
	}

	resp, err := c.client.Post("/postInstanceSet", "application/json",
		bytes.NewBuffer(data))
	if err != nil {
		logrus.Debug("error proxying post instance set")
		w.WriteHeader(resp.StatusCode)
		data, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			logrus.Debug("error reading result ", err)
			w.Write([]byte("No Response Available!"))
		} else {
			w.Write(data)
		}
		return
	}

	pid, err := GetPrincipalID(resp)
	if err != nil {
		logrus.Debug("error processing response: ", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Error processing proxy response"))
		return
	}
	p := Principal{
		Name:    m.OtherValues[0],
		ImageID: m.OtherValues[1],
		IP:      ip,
		PortMin: p1,
		PortMax: p2,
	}
	//overwrite it!
	ps, err := SerializePrincipal(&p)
	if err != nil {
		logrus.Debug("error serialize principal: ", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Error processing principal"))
		return
	}
	c.pmap.CreatePrincipal(ip, p1, p2, pid)
	c.store.Put(pid, ps)
}

func (c *MetadataProxy) retractInstanceSet(w http.ResponseWriter, r *http.Request) {
	m, data, status := ReadRequest(r)
	SetCommonHeader(w)
	if status != http.StatusOK {
		logrus.Debug("error reading request: ", status)
		return
	}
	ip, p1, p2, status := ParseIP(m.OtherValues[3])
	if status != http.StatusOK {
		logrus.Debug("error parsing the IP address: ", status)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Error parsing the IP address"))
		return
	}

	resp, err := c.client.Post(c.getUrl("/retractInstanceSet"), "application/json",
		bytes.NewBuffer(data))
	if err != nil {
		logrus.Debug("error proxying post instance set")
		w.WriteHeader(resp.StatusCode)
		data, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			logrus.Debug("error reading result ", err)
			w.Write([]byte("No Response Available!"))
		} else {
			w.Write(data)
		}
		return
	}
	pid, err := GetPrincipalID(resp)
	if err != nil {
		logrus.Debug("error processing response: ", err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Error processing proxy response"))
		return
	}
	c.store.Del(pid)
	c.pmap.DeletePrincipal(ip, p1, p2)
}

func (c *MetadataProxy) proxyAll(w http.ResponseWriter, r *http.Request) {
	outreq, err := http.NewRequest(r.Method, r.URL.String(), r.Body)
	if err != nil {
		logrus.Debug("error creating new http request: ", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	resp, err := c.client.Do(outreq)
	if err != nil {
		logrus.Debug("error processing proxy request: ", err)
		w.WriteHeader(resp.StatusCode)
		return
	}

	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		logrus.Debug("error reading the response from server: ", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.WriteHeader(resp.StatusCode)
	w.Write(data)
}

type BearerMetadataRequest struct {
	Principal   string
	BearerRef   string `json:"bearerRef"`
	OtherValues []string
}

func (c *MetadataProxy) marshalBearer(r *MetadataRequest) (io.Reader, error) {
	br := BearerMetadataRequest{
		Principal:   r.Principal,
		OtherValues: r.OtherValues,
	}

	matches := ipPortMatch.FindStringSubmatch(r.OtherValues[0])
	if len(matches) != 3 {
		logrus.Debug("error parsing the IP:port, actual", r.OtherValues[0])
		return nil, errors.New("error parsing IP:Port pair")
	}
	ip := matches[1]
	port, err := strconv.ParseInt(matches[2], 10, 32)
	if err != nil {
		logrus.Debug("error parsing the port int")
		return nil, err
	}

	pid, err := c.pmap.GetPrincipal(ip, int(port))
	if err != nil {
		logrus.Debugf("error searching for principal on %s:%d", ip, port)
		return nil, err
	}
	br.BearerRef = pid

	buf := bytes.Buffer{}
	encoder := json.NewEncoder(&buf)
	if err := encoder.Encode(&br); err != nil {
		logrus.Debug("error encoding the principal ", err, br)
		return nil, err
	}
	return &buf, nil
}

func (c *MetadataProxy) attest(w http.ResponseWriter, r *http.Request) {
	m, _, status := ReadRequest(r)
	if status != http.StatusOK {
		logrus.Debug("error reading request: ", status)
		w.WriteHeader(status)
		return
	}

	newBuf, err := c.marshalBearer(m)
	if err != nil {
		logrus.Debug("error finding bearer for incoming request ", err)
		w.WriteHeader(http.StatusNotFound)
		return
	}

	outreq, err := http.NewRequest(r.Method, r.URL.String(), newBuf)
	if err != nil {
		logrus.Debug("error creating new http request: ", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	resp, err := c.client.Do(outreq)
	if err != nil {
		logrus.Debug("error processing proxy request: ", err)
		w.WriteHeader(resp.StatusCode)
		return
	}

	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		logrus.Debug("error reading the response from server: ", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.WriteHeader(resp.StatusCode)
	w.Write(data)
}

func main() {

	flag.Parse()
	args := flag.Args()
	if len(args) < 1 {
		logrus.Errorf("must provide metadata to proxy for")
		os.Exit(1)
	}
	if len(args) >= 2 {
		logrus.SetLevel(logrus.DebugLevel)
	}
	client := MetadataProxy{
		client: &http.Client{
			Transport: &http.Transport{
				DisableCompression: true,
			},
		},
		pmap: NewPmap(),
	}
	eurosys18.RestartStore()

	server := kvstore.NewKvStore(client.proxyAll)
	server.AddRoute("/postInstanceSet", client.postInstanceSet, "")
	server.AddRoute("/retractInstanceSet", client.postInstanceSet, "")
	server.AddRoute("/updateSubjectSet", client.proxyAll, "")
	server.AddRoute("/postAttesterImage", client.proxyAll, "")
	server.AddRoute("/postObjectAcl", client.proxyAll, "")
	server.AddRoute("/postImageProperty", client.proxyAll, "")
	server.AddRoute("/attestInstance", client.attest, "")
	server.AddRoute("/attestAppProperty", client.attest, "")
	server.AddRoute("/appAccessesObject", client.attest, "")

	if err := server.ListenAndServe(eurosys18.MetadataProxyAddress); err != nil {
		logrus.Fatal("can not listen on address: ", err)
	}
}
