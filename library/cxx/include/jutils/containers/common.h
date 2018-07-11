

#ifndef _JUTILS_CONTAINERS_COMMON_H
#define _JUTILS_CONTAINERS_COMMON_H

#include <cstdio>
#include <utility>
#include <memory>
#include <string>

/*
 * TODO:
 * We should not use printf/putchar. We need a wrapper of stream. But
 * we don't want c++ stream, as it can be quite annoying somehow.
 */


/*
 *  Pretty print for the standard containers with begin/end
 */
namespace jutils {
  namespace containers {


template <typename T>
struct Shower {};

template <>
struct Shower<char> {
  void operator () (char v) const {
    printf("%c", v);
  }
};

template <>
struct Shower<int> {
  void operator () (int v) const {
    printf("%d", v);
  }
};

template <>
struct Shower<int64_t> {
  void operator () (int64_t v) const {
    printf("%ld", v);
  }
};

template <>
struct Shower<float> {
  void operator () (float v) const {
    printf("%f", v);
  }
};

template <>
struct Shower<double> {
  void operator () (double v) const {
    printf("%f", v);
  }
};

template <>
struct Shower<std::string> {
  void operator () (const std::string &v) const {
    printf("%s", v.c_str());
  }

  void operator () (std::string &&v) const {
    printf("%s", v.c_str());
  }
};

template <typename T1, typename T2>
struct Shower<std::pair<T1, T2>> {
  void operator () (const std::pair<T1, T2> &v) const {
    putchar('(');
    Shower<T1>()(v.first);
    putchar(',');
    Shower<T2>()(v.second);
    putchar(')');
  }
};


template <size_t idx, typename ...Tps>
struct TupleShowerImpl {
  void operator() (const std::tuple<Tps...> &v) const {
    TupleShowerImpl<idx - 1, Tps...>()(v);
    putchar(',');
    Shower<std::tuple_element<idx, std::tuple<Tps...>>>()(std::get<idx>(v));
  }
};
template <typename ...Tps>
struct TupleShowerImpl<0, Tps...> {
  void operator() (const std::tuple<Tps...> &v) const {
    Shower<std::tuple_element<0, std::tuple<Tps...>>>()(std::get<0>(v));
  }
};


template <typename ...Tps>
struct Shower<std::tuple<Tps...>> {
  void operator () (const std::tuple<Tps...> &v) const {
    constexpr size_t sz = std::tuple_size<std::tuple<Tps...>>::value;
    putchar('(');
    TupleShowerImpl<sz - 1, Tps...>()(v);
    putchar(')');
  }
};

template <typename Ctn, typename S=Shower<typename Ctn::value_type>>
  void show(const Ctn &c, S shower=S()) {
    show(c, 10, shower);
  }

template <typename Ctn, typename S=Shower<typename Ctn::value_type>>
  void show(const Ctn &c, int column, S shower=S()) {
    int counter = 0;
    for (auto i = c.begin(); i != c.end(); ++i) {
      shower(*i);
      if (++counter >= column) {
        counter = 0;
        putchar('\n');
      } else {
        putchar(' ');
      }
    }
    if (counter) putchar('\n');
  }


  } /// namespace containers

} /// namespace jutils


#endif
