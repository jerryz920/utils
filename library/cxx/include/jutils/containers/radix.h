
#ifndef _JUTILS_CONTAINERS_RADIX_H
#define _JUTILS_CONTAINERS_RADIX_H


#include "jutils/prefix.h"

namespace jutils {
  namespace containers {

class RadixTree: public PrefixTree {

  public:


    TreeNode *split(TreeNode *cur, const std::string &key) {
      return nullptr;
    }

    // Merge a node that has only one child,
    //
    void merge(TreeNode *cur) {
    }


  private:

};

}
}





#endif
