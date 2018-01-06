
///// an example of async echo server using
// unix domain socket. compile with -Lboost_system

#include <boost/asio/io_service.hpp>
#include <boost/asio.hpp>
#include <memory>
#include <ctime>
#include <iostream>
#include <string>
#include <boost/bind.hpp>
#include <boost/asio.hpp>
#include <sys/socket.h>
#include <sys/un.h>




#if defined (BOOST_ASIO_HAS_LOCAL_SOCKETS)

using boost::asio::local::stream_protocol;

class unix_connection
: public std::enable_shared_from_this<unix_connection>
{
  public:
    typedef std::shared_ptr<unix_connection> pointer;

    static pointer create(boost::asio::io_service &io_context)
    {
      return pointer(new unix_connection(io_context));
    }

    stream_protocol::socket& socket()
    {
      return socket_;
    }

    void start() {
      if (!authenticate()) {
        socket_.close();
      } else {
        wait_for_new_cmd();
      }
    }

  private:
    unix_connection(boost::asio::io_service& io_context)
      : socket_(io_context), read_ptr_(0), expect_size_(0)
    {
    }

    void header_received(const boost::system::error_code &ec, size_t len) {
      if (ec) {
        printf("receive error in header: %s\n", ec.message().c_str());
        socket_.close();
      } else if (len > 0) {
        expect_size_ = (data_[0]);
        boost::asio::async_read(socket_, boost::asio::buffer(&data_.at(1), expect_size_),
            std::bind(&unix_connection::data_received, shared_from_this(),
              std::placeholders::_1, std::placeholders::_2));
      }

    }

    void data_received(const boost::system::error_code &ec, size_t len) {
      if (ec) {
        printf("receive error in header: %s\n", ec.message().c_str());
        socket_.close();
      } else {
        printf("data received %zu, expect %zu\n", len, expect_size_);
        write(expect_size_);
      }
    }

    void echo_back(const boost::system::error_code &ec, size_t len) {
      if (ec) {
        printf("send error: %s\n", ec.message().c_str());
        socket_.close();
      } else {
        printf("%zu bytes sent out\n", len);
        wait_for_new_cmd();
      }

    }

    void wait_for_new_cmd() {
      boost::asio::async_read(socket_, boost::asio::buffer(data_, 1),
            std::bind(&unix_connection::header_received, shared_from_this(),
              std::placeholders::_1, std::placeholders::_2));
    }

    bool authenticate() {
      auto unix_fd_ = socket_.native_handle();
      struct ucred cred;
      socklen_t len = sizeof(cred);
      if (getsockopt(unix_fd_, SOL_SOCKET, SO_PEERCRED, &cred, &len) < 0) {
        perror("peercred");
        return false;
      } else {
        printf("credential is %u %u %u\n", cred.pid, cred.uid, cred.gid);
        return true;
      }
    }

    void write(size_t len) {
        boost::asio::async_write(socket_, boost::asio::buffer(data_, len + 1),
            std::bind(&unix_connection::echo_back, shared_from_this(),
              std::placeholders::_1, std::placeholders::_2));
    }

    stream_protocol::socket socket_;
    std::string message_;
    std::array<char, 8192> data_;
    size_t read_ptr_;
    size_t expect_size_;
};

class unix_server
{
  public:
    unix_server(boost::asio::io_service& io_context)
      : acceptor_(io_context, stream_protocol::endpoint("temp.sock"))
    {
      start_accept();
    }

  private:
    void start_accept()
    {
      {
      unix_connection::pointer new_connection =
        unix_connection::create(acceptor_.get_io_service());

      acceptor_.async_accept(new_connection->socket(),
          std::bind(&unix_server::handle_accept, this, new_connection,
            std::placeholders::_1));
      }
      printf("hey this is weird\n");
    }

    void handle_accept(unix_connection::pointer new_connection,
        const boost::system::error_code& error)
    {
      if (!error)
      {
        new_connection->start();
      }

      start_accept();
    }

    stream_protocol::acceptor acceptor_;
};

int main()
{
  try
  {
    unlink("temp.sock");
    boost::asio::io_service io_context;
    unix_server server(io_context);
    io_context.run();
  }
  catch (std::exception& e)
  {
    std::cerr << e.what() << std::endl;
  }

  return 0;
}

#else
# error Local sockets not available on this platform.
#endif
