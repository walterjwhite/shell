{
    bucket = $1;
    A[bucket] = A[bucket] + $4;
}

END {
    for (i in A) {
        print i, A[i];
    }
}

