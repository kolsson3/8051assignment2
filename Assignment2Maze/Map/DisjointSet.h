#ifndef  __DISJOINT_SET_H__
#define __DISJOINT_SET_H__
#if defined __cplusplus

class DisjointSet
{
public:
    DisjointSet(int setSize = 256);
    ~DisjointSet();
    
    int Find(int x);
    void UnionSets(int s1, int s2);
private:
    int *setArray;
};

#endif
#endif
