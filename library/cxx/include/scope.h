
#ifndef JUTILS_SCOPE_H
#define JUTILS_SCOPE_H

#include <memory>
template <typename DelayFunc, typename ...Args>
class DelayGuard {
  public:
    DelayGuard() = delete;
    DelayGuard(const DelayGuard&) = delete;
    DelayGuard(DelayGuard&& other) { f_ = std::move(other.f_); }

    DelayGuard(DelayFunc f, Args&&... args):
      f_(std::bind(f, std::forward<Args>(args)...)) {}
    ~DelayGuard() {printf("called:\n"); f_();}
  private:
    std::function<void(void)> f_;
};

template<typename DelayFunc, typename ...Args>
DelayGuard<DelayFunc, Args...> delay(DelayFunc f, Args&&... args) {
  return DelayGuard<DelayFunc, Args...>(f, std::forward<Args>(args)...);
}



#endif
