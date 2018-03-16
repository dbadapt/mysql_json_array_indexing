MySQL JSON Array Indexing

An example of using a child table and triggers to index a JSON array value

test output

```
$ ./run.sh
point query should return rows with arrays with the value 5
1       [1, 2, 3, 4, 5]
2       [4, 5, 6, 7, 8]
range query should return rows with arrays containing values greater than 8 and less than 11
3       [7, 8, 9, 10, 11]
4       [10, 11, 12, 13, 14]
modifing arrays to remove the value 5
1
2
all data after removing value 5
1       [1, 2, 3, 4]
2       [6, 7, 8, 4]
3       [7, 8, 9, 10, 11]
4       [10, 11, 12, 13, 14]
after update point query should return nothing when searching for 5
both tables should have 0 records
0
0
```

