package http

import (
	ghttp "net/http"

	"io/ioutil"

	mux "github.com/gorilla/mux"
	log "github.com/sirupsen/logrus"
)

type EchoServer struct {
	R *mux.Router
}

type EchoHandlerConfig struct {
	RetCode int
	Headers map[string]string
	Filter  func([]byte) []byte
}

func NewEchoServer() *EchoServer {
	r := mux.NewRouter()
	h := GetEchoHandler(&EchoHandlerConfig{
		RetCode: ghttp.StatusOK,
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
		Filter: nil,
	})
	r.HandleFunc("/", h)
	r.PathPrefix("/echo/").HandlerFunc(h)
	return &EchoServer{r}
}

func ProcessRequest(r *ghttp.Request) []byte {
	log.Info("***New Request***")
	log.Info(r.Method, " ", r.URL.String())
	log.Info("--------Request Headers------")
	for h, v := range r.Header {
		log.Info(h, ":", v)
	}
	if b, err := ioutil.ReadAll(r.Body); err != nil {
		log.Info("error in reading body ", err)
		return nil
	} else {
		log.Info("Content of body: ", string(b))
		return b
	}
}

func GetEchoHandler(c *EchoHandlerConfig) func(ghttp.ResponseWriter, *ghttp.Request) {

	// Make a copy so it references a new memory variable
	retCode := c.RetCode
	headers := make(map[string]string)
	filter := c.Filter
	for k, v := range c.Headers {
		headers[k] = v
	}

	return func(w ghttp.ResponseWriter, r *ghttp.Request) {
		defer r.Body.Close()
		b := ProcessRequest(r)
		for k, v := range headers {
			w.Header().Set(k, v)
		}
		w.WriteHeader(retCode)
		if filter != nil {
			w.Write(filter(b))
		}
	}
}

func (s *EchoServer) ListenAndServe(addr string) {
	ghttp.ListenAndServe(addr, s.R)
}
