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

type LoggedResponseWriter struct {
	ghttp.ResponseWriter
}

func (l LoggedResponseWriter) Write(b []byte) (int, error) {
	log.Infof("Response Content: %s", string(b))
	return l.ResponseWriter.Write(b)
}

func (l LoggedResponseWriter) WriteHeader(h int) {
	log.Infof("Response Status: %d", h)
	l.ResponseWriter.WriteHeader(h)
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
	if log.GetLevel() == log.DebugLevel {
		log.Debug("***New Request***")
		log.Debug(r.Method, " ", r.URL.String())
		log.Debug("--------Request Headers------")
		for h, v := range r.Header {
			log.Debug(h, ":", v)
		}
	}
	if b, err := ioutil.ReadAll(r.Body); err != nil {
		log.Error("error in reading body ", err)
		return nil
	} else {
		log.Debug("Content of body: ", string(b))
		return b
	}
}

func InspectHeader(r *ghttp.Request) {
	if log.GetLevel() == log.DebugLevel {
		log.Debug("***New Request***")
		log.Debug(r.Method, " ", r.URL.String())
		log.Debug("--------Request Headers------")
		for h, v := range r.Header {
			log.Debug(h, ":", v)
		}
	}
}

func GetEchoHandler(c *EchoHandlerConfig) ghttp.HandlerFunc {

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

func (s *EchoServer) AddRoute(path string, handler ghttp.HandlerFunc) {
	s.R.HandleFunc(path, func(w ghttp.ResponseWriter, r *ghttp.Request) {
		lw := LoggedResponseWriter{w}
		InspectHeader(r)
		handler(&lw, r)
	})
}
