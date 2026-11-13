#include <fstream>
#include <iostream>
#include <sstream>
#include "skaiciavimai.h"
#include "studentas.h"
#include "reading.h"

using namespace std;

konteineris fileread(std::string file){

    ifstream failas(file);
    konteineris sarasas;
    string eilute;

    if (!failas.is_open()){
        cout << "nepavyko atidaryti failo. galbut uzmirsai sugeneruot failus." << endl;
        return sarasas;
    }

    while (getline(failas, eilute)){

        if (eilute.empty()) continue;

        stringstream ss(eilute);
        string pavarde, vardas;
        ss >> pavarde >> vardas;

        vector<int> visiSkaiciai;
        int skaicius;
        
        while (ss >> skaicius) {
            visiSkaiciai.push_back(skaicius);
        }

        if (visiSkaiciai.empty()) continue;


        int egzrezultatas = visiSkaiciai.back();
        visiSkaiciai.pop_back();
        sarasas.push_back(studentas(vardas, pavarde, visiSkaiciai, egzrezultatas));
        
    }

    failas.close();
    return sarasas;

}