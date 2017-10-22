package http

import (
	ghttp "net/http"
	"path/filepath"
	"strings"

	mux "github.com/gorilla/mux"
)

const (
	APIPrefix = "/apis"
)

type APIServer struct {
	R *mux.Router
}

func NewAPIServer(rootFunc ghttp.HandlerFunc) (server *APIServer) {
	r := mux.NewRouter()
	server = &APIServer{r}
	if rootFunc == nil {
		r.HandleFunc("/", server.ListAPI)
	} else {
		r.HandleFunc("/", rootFunc)
	}
	r.HandleFunc(APIPrefix, server.ListAPI)
	return
}

func (s *APIServer) ListenAndServe(addr string) error {
	return ghttp.ListenAndServe(addr, s.R)
}

func (s *APIServer) AddRoute(path string, handler ghttp.HandlerFunc, desc string) {
	s.R.HandleFunc(path, func(w ghttp.ResponseWriter, r *ghttp.Request) {
		lw := LoggedResponseWriter{w}
		InspectHeader(r)
		handler(&lw, r)
	})
	/// Description handler
	if path != "/" {
		s.R.HandleFunc(filepath.Join(APIPrefix, path),
			func(w ghttp.ResponseWriter, r *ghttp.Request) {
				w.WriteHeader(ghttp.StatusOK)
				w.Write([]byte(desc + "\n"))
			})
	}
}

func (s *APIServer) ListAPI(w ghttp.ResponseWriter, r *ghttp.Request) {
	result := make([]string, 0)
	s.R.Walk(func(r *mux.Route, router *mux.Router, ancestors []*mux.Route) error {
		t, err := r.GetPathTemplate()
		if err != nil {
			return err
		}

		p, err := r.GetPathRegexp()
		if err != nil {
			return err
		}

		m, err := r.GetMethods()
		if err != nil {
			return err
		}
		result = append(result, strings.Join(m, ",")+" "+t+" "+p+"\n")
		return nil
	})
	for _, s := range result {
		w.Write([]byte(s))
	}
}
