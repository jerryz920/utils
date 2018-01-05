
#ifndef JUTILS_SCOPE_H
#define JUTILS_SCOPE_H

#include <memory>
template <typename DelayFunc, typename ...Args>
class DelayGuard {
  public:
    DelayGuard(DelayFunc f, Args&&... args):
      f_(std::bind(f, std::forward<Args>(args)...)) {}
    ~DelayGuard() {f_();}
  private:
    std::function<void(void)> f_;
};

template<typename DelayFunc, typename ...Args>
DelayGuard<DelayFunc, Args...> delay(DelayFunc f, Args&&... args) {
  return DelayGuard<DelayFunc, Args...>(f, std::forward<Args>(args)...);
}



#endif
