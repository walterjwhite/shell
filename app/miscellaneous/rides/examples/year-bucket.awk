func year(date) {
    return substr(date, 1, 4)
}

{
    bucket = year($1);
    A[bucket] = A[bucket] + $4;
}

END {
    for (i in A) {
        print i, A[i];
    }
}
