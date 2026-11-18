#!/bin/zsh
# struct (v1.0) vs class (v1.1) with -O1 / -O2 / -O3.
# Container: vector, strategy 3. Measures run time and executable size.
# Run from the repo root:  zsh benchmark_flags.zsh
# Results go to benchmark_flags.txt (git ignores it, copy the table into README.md).

RUNS=${RUNS:-5}     # how many times to repeat each test
SORT=1              # 1 = sort by name
STRAT=3             # strategy 3 = fastest with vector

ROOT=$PWD
BUILD=$(mktemp -d)  # compiled programs live here, not in the repo
OUT=$ROOT/benchmark_flags.txt

# the struct version = the code at tag v1.0
mkdir $BUILD/struct_src
git archive refs/tags/v1.0 | tar -x -C $BUILD/struct_src || exit 1

# the checksum every correct run must give (same as in benchmark_laikai.txt)
tiketina() {
    case $1 in
        100000)  echo 7214238e ;;
        1000000) echo f84ad3ac ;;
    esac
}

echo "versija  flag  exe_baitai  studentu  skaitymas  skirstymas  rikiavimas  rasymas  suma  busena" | tee $OUT

for versija in struct class; do
    if [[ $versija == struct ]]; then src=$BUILD/struct_src; else src=$ROOT; fi

    for flag in -O1 -O2 -O3; do
        exe=$BUILD/${versija}_${flag#-}
        g++ -std=c++17 $flag -DUSE_VECTOR $src/*.cpp -o $exe || { echo "KLAIDA: nepavyko sukompiliuoti $versija $flag"; exit 1; }
        dydis=$(wc -c < $exe | tr -d ' ')

        # "file number in the menu:studentu count"
        for pora in 3:100000 4:1000000; do
            failas=${pora%%:*}
            n=${pora##*:}
            rm -f $BUILD/laikai.tmp

            for k in $(seq 1 $RUNS); do
                printf '3\n1\n%s\n2\nY\n%s\n%s\n6\n' $failas $SORT $STRAT | $exe | head -c 200000 > $BUILD/izvestis.tmp

                if [[ $(grep -c "per:" $BUILD/izvestis.tmp) -ne 4 ]]; then
                    echo "KLAIDA: $versija $flag $n, patikrink $BUILD/izvestis.tmp"
                    exit 1
                fi

                grep "per:" $BUILD/izvestis.tmp | awk '{printf "%s ", $4} END {print ""}' >> $BUILD/laikai.tmp
            done

            suma=$(cat nerdai_studentai$n.txt nelaimingi_studentai$n.txt | shasum | cut -c1-8)
            if [[ $suma == $(tiketina $n) ]]; then busena=OK; else busena=SKIRTINGA; fi

            awk -v v=$versija -v f=$flag -v d=$dydis -v n=$n -v m="$suma $busena" \
                '{a+=$1; b+=$2; c+=$3; e+=$4} END {printf "%-7s  %s  %10d  %8d  %.5f  %.5f  %.5f  %.5f  %s\n", v, f, d, n, a/NR, b/NR, c/NR, e/NR, m}' $BUILD/laikai.tmp | tee -a $OUT
        done
    done
done

rm -rf $BUILD
