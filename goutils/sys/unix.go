package unix

import (
	"errors"
	"net"
	"syscall"

	"github.com/sirupsen/logrus"
)

func SendFd(conn *net.UnixConn, fd ...int) error {
	dummy := []byte{0}
	return SendFdMsg(conn, dummy, fd...)
}

func SendFdMsg(conn *net.UnixConn, data []byte, fd ...int) error {
	encodedFds := syscall.UnixRights(fd...)
	logrus.Debug("oob bytes: ", len(encodedFds))

	n, oobn, err := conn.WriteMsgUnix(data, encodedFds, nil)
	if err != nil {
		logrus.Debugf("error writing message: ", err)
		return err
	}

	if n != len(data) || oobn != len(encodedFds) {
		err := errors.New("error writing message: not enough bytes written")
		logrus.Error(err)
		return err
	}
	return nil
}
