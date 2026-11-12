#pragma once
#include <string>
#include <vector>
#include <list>
#include <algorithm>
#include "skaiciavimai.h"

class studentas{
    private:
        std::string vardas_;
        std::string pavarde_;
        std::vector<int> ndpazymiai_;
        int egzrezultatas_;
        double rezvidurkis_;
        double rezmedian_;
    public:
        studentas(const std::string& vardas, const std::string& pavarde, const std::vector<int>& ndpazymiai, const int egzrezultatas)
        : vardas_(vardas), pavarde_(pavarde), ndpazymiai_(ndpazymiai), egzrezultatas_(egzrezultatas), rezvidurkis_(vidurkiscalc(ndpazymiai, egzrezultatas)), rezmedian_(mediancalc(ndpazymiai, egzrezultatas)) {}

        const std::string& vardas() const {return vardas_;}
        const std::string& pavarde() const {return pavarde_;}
        double rezvidurkis() const {return rezvidurkis_;}
        double rezmedian() const {return rezmedian_;}
};

#ifdef USE_VECTOR
using konteineris = std::vector<studentas>;
#else
using konteineris = std::list<studentas>;
#endif // claude sugeneruota, kad galeciau atlikt greiciau benchmark'us

template <typename C, typename Cmp>
void rikiuoti(C& c, Cmp cmp){
    if constexpr (std::is_same_v<C, std::list<studentas>>){
        c.sort(cmp);
    } else {
        std::sort(c.begin(), c.end(), cmp);
    }
}