# How to run

```
make
$ swipl
?- [kakurosolver].
?- kakuro_solution(board(5, [
     tile_closed,        tile_head(12, 0),   tile_closed,        tile_closed,       tile_closed,
     tile_head(0, 8),    tile_open(A),       tile_open(B),       tile_open(C),      tile_closed,  
     tile_closed,        tile_open(D),       tile_closed,        tile_closed,       tile_closed, 
     tile_closed,        tile_open(E),       tile_closed,        tile_closed,       tile_closed,
     tile_closed,        tile_closed,        tile_closed,        tile_closed,       tile_closed 
   ])).
```