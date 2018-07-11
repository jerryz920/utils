
#ifndef _JUTILS_RADIX_H
#define _JUTILS_RADIX_H

// A radix tree interface

#include <string>
#include <list>
#include <memory>
namespace jutils {
  namespace containers {



class PrefixTree {

  public:
    class Iterator {
    };

    using iterator = Iterator;


    virtual iterator prefix(const std::string &key) = 0;
    virtual iterator prefix(const std::string &key, size_t pos, size_t len) = 0;
    virtual iterator insert(const std::string &key) = 0;
    virtual iterator remove(const std::string &key) = 0;
    virtual iterator lookup(const std::string &key) = 0;
    virtual iterator lookup(const std::string &key, size_t pos, size_t len) = 0;

};




}
}

#endif 
