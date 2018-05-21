

```python
%load_ext sql
```

    The sql extension is already loaded. To reload it, use:
      %reload_ext sql



```python
%sql postgresql://postgres@psql:5432/postgres
```




    'Connected: postgres@postgres'




```python
%sql EXPLAIN ANALYZE select * from books where author = 'William Shakespeare';
```

    5 rows affected.





<table>
    <tr>
        <th>QUERY PLAN</th>
    </tr>
    <tr>
        <td>Seq Scan on books  (cost=0.00..845.26 rows=2 width=50) (actual time=0.023..2.175 rows=21 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Filter: ((author)::text = &#x27;William Shakespeare&#x27;::text)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Rows Removed by Filter: 37200</td>
    </tr>
    <tr>
        <td>Planning time: 0.112 ms</td>
    </tr>
    <tr>
        <td>Execution time: 2.186 ms</td>
    </tr>
</table>




```python
%sql EXPLAIN ANALYSE select * from books where author = '%William Shakespeare%';
```

    5 rows affected.





<table>
    <tr>
        <th>QUERY PLAN</th>
    </tr>
    <tr>
        <td>Seq Scan on books  (cost=0.00..845.26 rows=2 width=50) (actual time=1.951..1.951 rows=0 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Filter: ((author)::text = &#x27;%William Shakespeare%&#x27;::text)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Rows Removed by Filter: 37221</td>
    </tr>
    <tr>
        <td>Planning time: 0.031 ms</td>
    </tr>
    <tr>
        <td>Execution time: 1.960 ms</td>
    </tr>
</table>




```python
%sql CREATE INDEX book_author_index ON books USING btree("author");
```

    Done.





    []




```python
%sql EXPLAIN ANALYZE select * from books where author like 'William Shakespeare';
```

    7 rows affected.





<table>
    <tr>
        <th>QUERY PLAN</th>
    </tr>
    <tr>
        <td>Bitmap Heap Scan on books  (cost=4.31..11.90 rows=2 width=50) (actual time=0.015..0.027 rows=21 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Filter: ((author)::text ~~ &#x27;William Shakespeare&#x27;::text)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Heap Blocks: exact=13</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;-&gt;  Bitmap Index Scan on book_author_index  (cost=0.00..4.30 rows=2 width=0) (actual time=0.010..0.010 rows=21 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Index Cond: ((author)::text = &#x27;William Shakespeare&#x27;::text)</td>
    </tr>
    <tr>
        <td>Planning time: 0.049 ms</td>
    </tr>
    <tr>
        <td>Execution time: 0.039 ms</td>
    </tr>
</table>




```python
%sql EXPLAIN ANALYSE select * from books where author like '%William Shakespeare%';
```

    5 rows affected.





<table>
    <tr>
        <th>QUERY PLAN</th>
    </tr>
    <tr>
        <td>Seq Scan on books  (cost=0.00..845.26 rows=3 width=50) (actual time=0.031..3.081 rows=25 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Filter: ((author)::text ~~ &#x27;%William Shakespeare%&#x27;::text)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Rows Removed by Filter: 37196</td>
    </tr>
    <tr>
        <td>Planning time: 0.043 ms</td>
    </tr>
    <tr>
        <td>Execution time: 3.092 ms</td>
    </tr>
</table>




```python
%%sql Explain analyse
select cities.name, cities.latitude, cities.longitude, books.id, books.title from cities
join mentions on (cities.id = mentions.cityid)
join books on (mentions.bookid = books.id)
where geodistance(latitude, longitude, 52.38, 11.47) < 50;
```

    15 rows affected.





<table>
    <tr>
        <th>QUERY PLAN</th>
    </tr>
    <tr>
        <td>Hash Join  (cost=4617.72..51832.64 rows=488186 width=60) (actual time=23.957..215.241 rows=1254 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Hash Cond: (mentions.bookid = books.id)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;-&gt;  Hash Join  (cost=3400.25..44451.93 rows=488186 width=30) (actual time=10.685..201.461 rows=1254 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hash Cond: (mentions.cityid = cities.id)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on mentions  (cost=0.00..22562.28 rows=1464528 width=8) (actual time=0.015..91.315 rows=1464528 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash  (cost=3198.68..3198.68 rows=16126 width=30) (actual time=10.317..10.317 rows=69 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Buckets: 16384  Batches: 1  Memory Usage: 133kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on cities  (cost=0.00..3198.68 rows=16126 width=30) (actual time=1.958..10.284 rows=69 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Filter: ((asin(sqrt(((sin((radians((&#x27;52.38&#x27;::double precision - latitude)) / &#x27;2&#x27;::double precision)) ^ &#x27;2&#x27;::double precision) + (((sin((radians((&#x27;11.47&#x27;::double precision - longitude)) / &#x27;2&#x27;::double precision)) ^ &#x27;2&#x27;::double precision) * cos(radians(latitude))) * &#x27;0.610421687981602&#x27;::double precision)))) * &#x27;7926.3352&#x27;::double precision) &lt; &#x27;50&#x27;::double precision)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Rows Removed by Filter: 48308</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;-&gt;  Hash  (cost=752.21..752.21 rows=37221 width=34) (actual time=13.151..13.151 rows=37221 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Buckets: 65536  Batches: 1  Memory Usage: 2930kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on books  (cost=0.00..752.21 rows=37221 width=34) (actual time=0.005..4.108 rows=37221 loops=1)</td>
    </tr>
    <tr>
        <td>Planning time: 0.625 ms</td>
    </tr>
    <tr>
        <td>Execution time: 215.424 ms</td>
    </tr>
</table>



```
Note: Testing has shown PostgreSQL's hash indexes to perform no better than B-tree indexes, and the index size and build time for hash indexes is much worse. Furthermore, hash index operations are not presently WAL-logged, so hash indexes may need to be rebuilt with REINDEX after a database crash. For these reasons, hash index use is presently discouraged.

Similarly, R-tree indexes do not seem to have any performance advantages compared to the equivalent operations of GiST indexes. Like hash indexes, they are not WAL-logged and may need reindexing after a database crash.

While the problems with hash indexes may be fixed eventually, it is likely that the R-tree index type will be retired in a future release. Users are encouraged to migrate applications that use R-tree indexes to GiST indexes.
```


```python
%sql create extension earthdistance cascade;
```

    Done.





    []




```python
%sql CREATE INDEX latitude_longitude_index ON cities USING gist (ll_to_earth(latitude, longitude));
```

    Done.





    []




```python
%sql drop index latitude_longitude_index;
```

    Done.





    []




```python
%%sql Explain analyse
select cities.name, cities.latitude, cities.longitude, books.id, books.title from cities
join mentions on (cities.id = mentions.cityid)
join books on (mentions.bookid = books.id)
where earth_distance(ll_to_earth(52.38, 11.47), ll_to_earth(latitude, longitude)) < 50;
```

    15 rows affected.





<table>
    <tr>
        <th>QUERY PLAN</th>
    </tr>
    <tr>
        <td>Hash Join  (cost=26750.20..73965.12 rows=488186 width=60) (actual time=345.597..345.597 rows=0 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Hash Cond: (mentions.bookid = books.id)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;-&gt;  Hash Join  (cost=25532.73..66584.41 rows=488186 width=30) (actual time=333.936..333.936 rows=0 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hash Cond: (mentions.cityid = cities.id)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on mentions  (cost=0.00..22562.28 rows=1464528 width=8) (actual time=0.007..0.007 rows=1 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash  (cost=25331.15..25331.15 rows=16126 width=30) (actual time=333.920..333.920 rows=0 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Buckets: 16384  Batches: 1  Memory Usage: 128kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on cities  (cost=0.00..25331.15 rows=16126 width=30) (actual time=333.919..333.919 rows=0 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Filter: (sec_to_gc(cube_distance(&#x27;(3815617.38379195, 774215.802496072, 5051997.71455748)&#x27;::cube, (ll_to_earth(latitude, longitude))::cube)) &lt; &#x27;50&#x27;::double precision)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Rows Removed by Filter: 48377</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;-&gt;  Hash  (cost=752.21..752.21 rows=37221 width=34) (actual time=11.550..11.550 rows=37221 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Buckets: 65536  Batches: 1  Memory Usage: 2930kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on books  (cost=0.00..752.21 rows=37221 width=34) (actual time=0.004..3.498 rows=37221 loops=1)</td>
    </tr>
    <tr>
        <td>Planning time: 0.417 ms</td>
    </tr>
    <tr>
        <td>Execution time: 345.715 ms</td>
    </tr>
</table>




```python
%%sql Explain analyse
select cities.name, cities.latitude, cities.longitude, books.id, books.title from cities
join mentions on (cities.id = mentions.cityid)
join books on (mentions.bookid = books.id)
where earth_box(ll_to_earth(52.38, 11.47), 50000) @> ll_to_earth(latitude, longitude);
```

    18 rows affected.





<table>
    <tr>
        <th>QUERY PLAN</th>
    </tr>
    <tr>
        <td>Gather  (cost=1156.31..23211.26 rows=1453 width=60) (actual time=1.161..208.811 rows=825 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Workers Planned: 2</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;Workers Launched: 2</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;-&gt;  Nested Loop  (cost=156.31..22065.96 rows=605 width=60) (actual time=1.489..200.474 rows=275 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash Join  (cost=156.02..21879.13 rows=605 width=30) (actual time=1.477..199.733 rows=275 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hash Cond: (mentions.cityid = cities.id)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Parallel Seq Scan on mentions  (cost=0.00..14019.20 rows=610220 width=8) (actual time=0.006..99.702 rows=488176 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash  (cost=155.42..155.42 rows=48 width=30) (actual time=0.123..0.123 rows=38 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Buckets: 1024  Batches: 1  Memory Usage: 11kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Bitmap Heap Scan on cities  (cost=4.65..155.42 rows=48 width=30) (actual time=0.094..0.115 rows=38 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Recheck Cond: (&#x27;(3765617.51182041, 724215.930524535, 5001997.84258595),(3865617.25576349, 824215.67446761, 5101997.58652902)&#x27;::cube @&gt; (ll_to_earth(latitude, longitude))::cube)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Heap Blocks: exact=19</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Bitmap Index Scan on latitude_longitude_index  (cost=0.00..4.64 rows=48 width=0) (actual time=0.089..0.089 rows=38 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Index Cond: (&#x27;(3765617.51182041, 724215.930524535, 5001997.84258595),(3865617.25576349, 824215.67446761, 5101997.58652902)&#x27;::cube @&gt; (ll_to_earth(latitude, longitude))::cube)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Index Scan using books_pkey on books  (cost=0.29..0.31 rows=1 width=34) (actual time=0.002..0.002 rows=1 loops=825)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Index Cond: (id = mentions.bookid)</td>
    </tr>
    <tr>
        <td>Planning time: 0.424 ms</td>
    </tr>
    <tr>
        <td>Execution time: 209.236 ms</td>
    </tr>
</table>




```python
%%sql explain analyse
select distinct on (cities.name) cities.name, cities.latitude, cities.longitude, books.id, books.title from cities
join mentions on (cities.id = mentions.cityid)
join books on (mentions.bookid = books.id)
where earth_box(ll_to_earth(52.38, 11.47), 50000) @> ll_to_earth(latitude, longitude)
and earth_distance(ll_to_earth(52.38, 11.47), ll_to_earth(latitude, longitude)) < 50000;
```

    24 rows affected.





<table>
    <tr>
        <th>QUERY PLAN</th>
    </tr>
    <tr>
        <td>Unique  (cost=23035.33..23037.75 rows=16 width=60) (actual time=214.468..214.541 rows=12 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;-&gt;  Sort  (cost=23035.33..23036.54 rows=484 width=60) (actual time=214.467..214.494 rows=673 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sort Key: cities.name</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sort Method: quicksort  Memory: 120kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Gather  (cost=1180.14..23013.74 rows=484 width=60) (actual time=1.723..214.284 rows=673 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Workers Planned: 2</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Workers Launched: 2</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Nested Loop  (cost=180.14..21965.34 rows=202 width=60) (actual time=6.853..207.154 rows=224 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash Join  (cost=179.85..21902.96 rows=202 width=30) (actual time=6.838..203.561 rows=224 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hash Cond: (mentions.cityid = cities.id)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Parallel Seq Scan on mentions  (cost=0.00..14019.20 rows=610220 width=8) (actual time=0.007..93.291 rows=488176 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash  (cost=179.65..179.65 rows=16 width=30) (actual time=3.258..3.258 rows=25 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Buckets: 1024  Batches: 1  Memory Usage: 10kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Bitmap Heap Scan on cities  (cost=4.64..179.65 rows=16 width=30) (actual time=2.300..3.249 rows=25 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Recheck Cond: (&#x27;(3765617.51182041, 724215.930524535, 5001997.84258595),(3865617.25576349, 824215.67446761, 5101997.58652902)&#x27;::cube @&gt; (ll_to_earth(latitude, longitude))::cube)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Filter: (sec_to_gc(cube_distance(&#x27;(3815617.38379195, 774215.802496072, 5051997.71455748)&#x27;::cube, (ll_to_earth(latitude, longitude))::cube)) &lt; &#x27;50000&#x27;::double precision)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Rows Removed by Filter: 13</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Heap Blocks: exact=19</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Bitmap Index Scan on latitude_longitude_index  (cost=0.00..4.64 rows=48 width=0) (actual time=1.298..1.298 rows=38 loops=3)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Index Cond: (&#x27;(3765617.51182041, 724215.930524535, 5001997.84258595),(3865617.25576349, 824215.67446761, 5101997.58652902)&#x27;::cube @&gt; (ll_to_earth(latitude, longitude))::cube)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Index Scan using books_pkey on books  (cost=0.29..0.31 rows=1 width=34) (actual time=0.015..0.015 rows=1 loops=673)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Index Cond: (id = mentions.bookid)</td>
    </tr>
    <tr>
        <td>Planning time: 0.511 ms</td>
    </tr>
    <tr>
        <td>Execution time: 215.223 ms</td>
    </tr>
</table>




```python
%%sql explain analyse
select distinct on (cities.name) cities.name, cities.latitude, cities.longitude, books.id, books.title,
earth_distance(ll_to_earth(52.38, 11.47), ll_to_earth(latitude, longitude)) as distance
from cities
left outer join mentions on (cities.id = mentions.cityid)
left outer join books on (mentions.bookid = books.id)
where earth_distance(ll_to_earth(52.38, 11.47), ll_to_earth(latitude, longitude)) < 50000;
```

    19 rows affected.





<table>
    <tr>
        <th>QUERY PLAN</th>
    </tr>
    <tr>
        <td>Unique  (cost=385428.51..387869.44 rows=15747 width=68) (actual time=538.746..538.836 rows=25 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;-&gt;  Sort  (cost=385428.51..386648.97 rows=488186 width=68) (actual time=538.745..538.787 rows=686 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sort Key: cities.name</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sort Method: quicksort  Memory: 125kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash Left Join  (cost=26750.20..319278.58 rows=488186 width=68) (actual time=339.955..538.511 rows=686 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hash Cond: (mentions.bookid = books.id)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash Right Join  (cost=25532.73..66584.41 rows=488186 width=30) (actual time=330.139..521.889 rows=686 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hash Cond: (mentions.cityid = cities.id)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on mentions  (cost=0.00..22562.28 rows=1464528 width=8) (actual time=0.008..91.965 rows=1464528 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash  (cost=25331.15..25331.15 rows=16126 width=30) (actual time=329.380..329.380 rows=25 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Buckets: 16384  Batches: 1  Memory Usage: 130kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on cities  (cost=0.00..25331.15 rows=16126 width=30) (actual time=62.940..329.361 rows=25 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Filter: (sec_to_gc(cube_distance(&#x27;(3815617.38379195, 774215.802496072, 5051997.71455748)&#x27;::cube, (ll_to_earth(latitude, longitude))::cube)) &lt; &#x27;50000&#x27;::double precision)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Rows Removed by Filter: 48352</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash  (cost=752.21..752.21 rows=37221 width=34) (actual time=9.500..9.500 rows=37221 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Buckets: 65536  Batches: 1  Memory Usage: 2930kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on books  (cost=0.00..752.21 rows=37221 width=34) (actual time=0.004..3.917 rows=37221 loops=1)</td>
    </tr>
    <tr>
        <td>Planning time: 0.417 ms</td>
    </tr>
    <tr>
        <td>Execution time: 538.953 ms</td>
    </tr>
</table>




```python
%%sql explain analyse
select distinct on (cities.name) cities.name, cities.latitude, cities.longitude, books.id, books.title,
earth_distance(ll_to_earth(52.38, 11.47), ll_to_earth(latitude, longitude)) as distance
from cities
join mentions on (cities.id = mentions.cityid)
join books on (mentions.bookid = books.id)
where earth_distance(ll_to_earth(52.38, 11.47), ll_to_earth(latitude, longitude)) < 50000;
```

    19 rows affected.





<table>
    <tr>
        <th>QUERY PLAN</th>
    </tr>
    <tr>
        <td>Unique  (cost=385428.51..387869.44 rows=15747 width=68) (actual time=527.561..527.635 rows=12 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;-&gt;  Sort  (cost=385428.51..386648.97 rows=488186 width=68) (actual time=527.560..527.588 rows=673 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sort Key: cities.name</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sort Method: quicksort  Memory: 124kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash Join  (cost=26750.20..319278.58 rows=488186 width=68) (actual time=337.754..527.386 rows=673 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hash Cond: (mentions.bookid = books.id)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash Join  (cost=25532.73..66584.41 rows=488186 width=30) (actual time=326.853..510.245 rows=673 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hash Cond: (mentions.cityid = cities.id)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on mentions  (cost=0.00..22562.28 rows=1464528 width=8) (actual time=0.010..86.996 rows=1464528 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash  (cost=25331.15..25331.15 rows=16126 width=30) (actual time=326.100..326.100 rows=25 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Buckets: 16384  Batches: 1  Memory Usage: 130kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on cities  (cost=0.00..25331.15 rows=16126 width=30) (actual time=59.114..326.087 rows=25 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Filter: (sec_to_gc(cube_distance(&#x27;(3815617.38379195, 774215.802496072, 5051997.71455748)&#x27;::cube, (ll_to_earth(latitude, longitude))::cube)) &lt; &#x27;50000&#x27;::double precision)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Rows Removed by Filter: 48352</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Hash  (cost=752.21..752.21 rows=37221 width=34) (actual time=10.630..10.630 rows=37221 loops=1)</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Buckets: 65536  Batches: 1  Memory Usage: 2930kB</td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&gt;  Seq Scan on books  (cost=0.00..752.21 rows=37221 width=34) (actual time=0.005..3.546 rows=37221 loops=1)</td>
    </tr>
    <tr>
        <td>Planning time: 0.456 ms</td>
    </tr>
    <tr>
        <td>Execution time: 527.758 ms</td>
    </tr>
</table>




```python
%sql create extension btree_gist;
```

    Done.





    []




```python
%%sql
select distinct on (cities.name) cities.name, cities.latitude, cities.longitude, books.id, books.title from cities
join mentions on (cities.id = mentions.cityid)
join books on (mentions.bookid = books.id)
where geodistance(latitude, longitude, 52.38, 11.47) < 50;
```

    36 rows affected.





<table>
    <tr>
        <th>name</th>
        <th>latitude</th>
        <th>longitude</th>
        <th>id</th>
        <th>title</th>
    </tr>
    <tr>
        <td>Aschersleben</td>
        <td>51.75742</td>
        <td>11.46084</td>
        <td>20136</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 4· Slice 4</td>
    </tr>
    <tr>
        <td>Ballenstedt</td>
        <td>51.719</td>
        <td>11.23265</td>
        <td>25302</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 13· Slice 1</td>
    </tr>
    <tr>
        <td>Bernburg</td>
        <td>51.79464</td>
        <td>11.7401</td>
        <td>29965</td>
        <td>History of the Jews· Vol. V (of 6)</td>
    </tr>
    <tr>
        <td>Braunschweig</td>
        <td>52.26594</td>
        <td>10.52673</td>
        <td>7825</td>
        <td>Germany and the Germans</td>
    </tr>
    <tr>
        <td>Calbe</td>
        <td>51.90668</td>
        <td>11.77478</td>
        <td>8478</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 4· Part 4</td>
    </tr>
    <tr>
        <td>Dessau</td>
        <td>51.83864</td>
        <td>12.24555</td>
        <td>9360</td>
        <td>English Past and Present</td>
    </tr>
    <tr>
        <td>Gardelegen</td>
        <td>52.5252</td>
        <td>11.39523</td>
        <td>26731</td>
        <td>The Assault</td>
    </tr>
    <tr>
        <td>Genthin</td>
        <td>52.40668</td>
        <td>12.1592</td>
        <td>18539</td>
        <td>Tales from the German</td>
    </tr>
    <tr>
        <td>Gommern</td>
        <td>52.07391</td>
        <td>11.82297</td>
        <td>27471</td>
        <td>The Golden Bough (Third Edition· Vol. 7 of 12)</td>
    </tr>
    <tr>
        <td>Halberstadt</td>
        <td>51.89562</td>
        <td>11.05622</td>
        <td>34688</td>
        <td>The Project Gutenberg Works of Frederich Schiller in English</td>
    </tr>
    <tr>
        <td>Havelberg</td>
        <td>52.83088</td>
        <td>12.07552</td>
        <td>9471</td>
        <td>History Of Friedrich II. of Prussia· Volume IV. (of XXI.)</td>
    </tr>
    <tr>
        <td>Helmstedt</td>
        <td>52.2279</td>
        <td>11.00985</td>
        <td>28485</td>
        <td>The Criminal Prosecution and Capital Punishment of Animals</td>
    </tr>
    <tr>
        <td>Ilsenburg</td>
        <td>51.86695</td>
        <td>10.67817</td>
        <td>22338</td>
        <td>Arts and Crafts Essays</td>
    </tr>
    <tr>
        <td>Kloetze</td>
        <td>52.62725</td>
        <td>11.16424</td>
        <td>22852</td>
        <td>The Vulture Maiden</td>
    </tr>
    <tr>
        <td>Koethen</td>
        <td>51.75185</td>
        <td>11.97093</td>
        <td>36432</td>
        <td>The Atlantic Monthly· Vol. I.· No. 3· January 1858</td>
    </tr>
    <tr>
        <td>Lehre</td>
        <td>52.33333</td>
        <td>10.66667</td>
        <td>23880</td>
        <td>A Literary History of the Arabs</td>
    </tr>
    <tr>
        <td>Luechow</td>
        <td>52.96811</td>
        <td>11.15397</td>
        <td>23646</td>
        <td>For Sceptre and Crown· Vol. I (of II)</td>
    </tr>
    <tr>
        <td>Magdeburg</td>
        <td>52.12773</td>
        <td>11.62916</td>
        <td>27641</td>
        <td>The Southern South</td>
    </tr>
    <tr>
        <td>Meinersen</td>
        <td>52.47436</td>
        <td>10.35247</td>
        <td>2003</td>
        <td>Balder The Beautiful· Vol. I.</td>
    </tr>
    <tr>
        <td>Moeckern</td>
        <td>52.14099</td>
        <td>11.95203</td>
        <td>3801</td>
        <td>The Life of Napoleon I (Volumes· 1 and 2)</td>
    </tr>
    <tr>
        <td>Osterburg</td>
        <td>52.78721</td>
        <td>11.75297</td>
        <td>20814</td>
        <td>A Biographical Dictionary of Freethinkers of All Ages and Nations</td>
    </tr>
    <tr>
        <td>Quedlinburg</td>
        <td>51.78843</td>
        <td>11.15006</td>
        <td>21151</td>
        <td>Woman in Science</td>
    </tr>
    <tr>
        <td>Rathenow</td>
        <td>52.60659</td>
        <td>12.33696</td>
        <td>3953</td>
        <td>The German Classics Of The Nineteenth And Twentieth Centuries· Volume 12</td>
    </tr>
    <tr>
        <td>Rosslau</td>
        <td>51.88736</td>
        <td>12.24192</td>
        <td>3215</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 2· Part 1· Slice 1</td>
    </tr>
    <tr>
        <td>Salzwedel</td>
        <td>52.85435</td>
        <td>11.1525</td>
        <td>26577</td>
        <td>The Golden Bough (Vol. 1 of 2)</td>
    </tr>
    <tr>
        <td>Schoenebeck</td>
        <td>52.01682</td>
        <td>11.7307</td>
        <td>14556</td>
        <td>The Life of Trust: Being a Narrative of the Lord&#x27;s Dealings With George Mueller</td>
    </tr>
    <tr>
        <td>Stassfurt</td>
        <td>51.85186</td>
        <td>11.58508</td>
        <td>9320</td>
        <td>An Elementary Study of Chemistry</td>
    </tr>
    <tr>
        <td>Tangermuende</td>
        <td>52.54463</td>
        <td>11.97647</td>
        <td>10009</td>
        <td>In and Around Berlin</td>
    </tr>
    <tr>
        <td>Thale</td>
        <td>51.74861</td>
        <td>11.041</td>
        <td>26580</td>
        <td>Randolph Caldecott</td>
    </tr>
    <tr>
        <td>Wanzleben</td>
        <td>52.06087</td>
        <td>11.4408</td>
        <td>27471</td>
        <td>The Golden Bough (Third Edition· Vol. 7 of 12)</td>
    </tr>
    <tr>
        <td>Wernigerode</td>
        <td>51.83652</td>
        <td>10.78216</td>
        <td>26372</td>
        <td>History of the Reformation in the Sixteenth Century (Volume 1)</td>
    </tr>
    <tr>
        <td>Wittenberge</td>
        <td>53.00543</td>
        <td>11.75032</td>
        <td>20007</td>
        <td>Pharos· The Egyptian</td>
    </tr>
    <tr>
        <td>Wittingen</td>
        <td>52.72694</td>
        <td>10.73613</td>
        <td>29606</td>
        <td>Plant Lore· Legends· and Lyrics</td>
    </tr>
    <tr>
        <td>Wolfenbuettel</td>
        <td>52.16442</td>
        <td>10.54095</td>
        <td>25221</td>
        <td>Medieval English Nunneries c. 1275 to 1535</td>
    </tr>
    <tr>
        <td>Wolfsburg</td>
        <td>52.42452</td>
        <td>10.7815</td>
        <td>24632</td>
        <td>Tales From the &#x27;Phantasus&#x27;· etc. of Ludwig Tieck</td>
    </tr>
    <tr>
        <td>Zerbst</td>
        <td>51.9662</td>
        <td>12.08517</td>
        <td>25387</td>
        <td>The Life of Philip Melanchthon</td>
    </tr>
</table>




```python
%%sql
select distinct on (cities.name) cities.name, cities.latitude, cities.longitude, books.id, books.title from cities
join mentions on (cities.id = mentions.cityid)
join books on (mentions.bookid = books.id)
where earth_box(ll_to_earth(52.38, 11.47), 50000*1.6) @> ll_to_earth(latitude, longitude);
```

    53 rows affected.





<table>
    <tr>
        <th>name</th>
        <th>latitude</th>
        <th>longitude</th>
        <th>id</th>
        <th>title</th>
    </tr>
    <tr>
        <td>Aschersleben</td>
        <td>51.75742</td>
        <td>11.46084</td>
        <td>8929</td>
        <td>A Narrative of Some of the Lord&#x27;s Dealings with George Mueller</td>
    </tr>
    <tr>
        <td>Ballenstedt</td>
        <td>51.719</td>
        <td>11.23265</td>
        <td>27931</td>
        <td>The Violoncello and Its History</td>
    </tr>
    <tr>
        <td>Bernburg</td>
        <td>51.79464</td>
        <td>11.7401</td>
        <td>6533</td>
        <td>The Black Death· and The Dancing Mania</td>
    </tr>
    <tr>
        <td>Braunlage</td>
        <td>51.72651</td>
        <td>10.6109</td>
        <td>26580</td>
        <td>Randolph Caldecott</td>
    </tr>
    <tr>
        <td>Braunschweig</td>
        <td>52.26594</td>
        <td>10.52673</td>
        <td>29979</td>
        <td>The Rise of the Russian Empire</td>
    </tr>
    <tr>
        <td>Calbe</td>
        <td>51.90668</td>
        <td>11.77478</td>
        <td>27471</td>
        <td>The Golden Bough (Third Edition· Vol. 7 of 12)</td>
    </tr>
    <tr>
        <td>Coswig</td>
        <td>51.88618</td>
        <td>12.45009</td>
        <td>14275</td>
        <td>Historical Introductions to the Symbolical Books of the Evangelical Lutheran Church</td>
    </tr>
    <tr>
        <td>Dannenberg</td>
        <td>53.0967</td>
        <td>11.09001</td>
        <td>28798</td>
        <td>Female Warriors· Vol. II (of 2)</td>
    </tr>
    <tr>
        <td>Delitzsch</td>
        <td>51.52546</td>
        <td>12.34284</td>
        <td>30145</td>
        <td>The City of God· Volume I</td>
    </tr>
    <tr>
        <td>Dessau</td>
        <td>51.83864</td>
        <td>12.24555</td>
        <td>18907</td>
        <td>Tales from the German.  Volume II.</td>
    </tr>
    <tr>
        <td>Fehrbellin</td>
        <td>52.8135</td>
        <td>12.7644</td>
        <td>9534</td>
        <td>History of Friedrich II. of Prussia· Vol. X. (of XXI.)</td>
    </tr>
    <tr>
        <td>Gardelegen</td>
        <td>52.5252</td>
        <td>11.39523</td>
        <td>23126</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 11· Slice 4</td>
    </tr>
    <tr>
        <td>Genthin</td>
        <td>52.40668</td>
        <td>12.1592</td>
        <td>18539</td>
        <td>Tales from the German</td>
    </tr>
    <tr>
        <td>Gommern</td>
        <td>52.07391</td>
        <td>11.82297</td>
        <td>26577</td>
        <td>The Golden Bough (Vol. 1 of 2)</td>
    </tr>
    <tr>
        <td>Goslar</td>
        <td>51.90425</td>
        <td>10.42766</td>
        <td>22535</td>
        <td>A History of Germany</td>
    </tr>
    <tr>
        <td>Graefenhainichen</td>
        <td>51.72892</td>
        <td>12.45651</td>
        <td>17123</td>
        <td>Paul Gerhardt&#x27;s Spiritual Songs</td>
    </tr>
    <tr>
        <td>Halberstadt</td>
        <td>51.89562</td>
        <td>11.05622</td>
        <td>20438</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 2· Slice 4</td>
    </tr>
    <tr>
        <td>Havelberg</td>
        <td>52.83088</td>
        <td>12.07552</td>
        <td>3791</td>
        <td>The Life of Napoleon I (Volume 2 of 2)</td>
    </tr>
    <tr>
        <td>Helmstedt</td>
        <td>52.2279</td>
        <td>11.00985</td>
        <td>25221</td>
        <td>Medieval English Nunneries c. 1275 to 1535</td>
    </tr>
    <tr>
        <td>Hettstedt</td>
        <td>51.6503</td>
        <td>11.51146</td>
        <td>23905</td>
        <td>De Re Metallica</td>
    </tr>
    <tr>
        <td>Ilsenburg</td>
        <td>51.86695</td>
        <td>10.67817</td>
        <td>16678</td>
        <td>Mark Twain· A Biography· Vol. 2· Part 2· 1886-1900</td>
    </tr>
    <tr>
        <td>Kloetze</td>
        <td>52.62725</td>
        <td>11.16424</td>
        <td>22852</td>
        <td>The Vulture Maiden</td>
    </tr>
    <tr>
        <td>Koethen</td>
        <td>51.75185</td>
        <td>11.97093</td>
        <td>15065</td>
        <td>History of Education</td>
    </tr>
    <tr>
        <td>Kyritz</td>
        <td>52.94212</td>
        <td>12.39704</td>
        <td>27901</td>
        <td>The Grey Friars in Oxford</td>
    </tr>
    <tr>
        <td>Lauenburg</td>
        <td>53.37199</td>
        <td>10.55654</td>
        <td>32122</td>
        <td>One Year in Scandinavia</td>
    </tr>
    <tr>
        <td>Lehre</td>
        <td>52.33333</td>
        <td>10.66667</td>
        <td>23880</td>
        <td>A Literary History of the Arabs</td>
    </tr>
    <tr>
        <td>Leipzig</td>
        <td>51.33962</td>
        <td>12.37129</td>
        <td>18587</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 7· Slice 3</td>
    </tr>
    <tr>
        <td>Luechow</td>
        <td>52.96811</td>
        <td>11.15397</td>
        <td>23646</td>
        <td>For Sceptre and Crown· Vol. I (of II)</td>
    </tr>
    <tr>
        <td>Magdeburg</td>
        <td>52.12773</td>
        <td>11.62916</td>
        <td>14003</td>
        <td>George Muller of Bristol</td>
    </tr>
    <tr>
        <td>Meinersen</td>
        <td>52.47436</td>
        <td>10.35247</td>
        <td>2003</td>
        <td>Balder The Beautiful· Vol. I.</td>
    </tr>
    <tr>
        <td>Moeckern</td>
        <td>52.14099</td>
        <td>11.95203</td>
        <td>14866</td>
        <td>Principles Of Political Economy</td>
    </tr>
    <tr>
        <td>Neuruppin</td>
        <td>52.92815</td>
        <td>12.80311</td>
        <td>23719</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 11· Slice 1  Franciscans  to  French Language</td>
    </tr>
    <tr>
        <td>Osterburg</td>
        <td>52.78721</td>
        <td>11.75297</td>
        <td>20814</td>
        <td>A Biographical Dictionary of Freethinkers of All Ages and Nations</td>
    </tr>
    <tr>
        <td>Perleberg</td>
        <td>53.07583</td>
        <td>11.85739</td>
        <td>20385</td>
        <td>The Popes and Science</td>
    </tr>
    <tr>
        <td>Pritzwalk</td>
        <td>53.14945</td>
        <td>12.17405</td>
        <td>20385</td>
        <td>The Popes and Science</td>
    </tr>
    <tr>
        <td>Quedlinburg</td>
        <td>51.78843</td>
        <td>11.15006</td>
        <td>2075</td>
        <td>The Nuttall Encyclopaedia</td>
    </tr>
    <tr>
        <td>Rathenow</td>
        <td>52.60659</td>
        <td>12.33696</td>
        <td>21300</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 9· Slice 2</td>
    </tr>
    <tr>
        <td>Rosslau</td>
        <td>51.88736</td>
        <td>12.24192</td>
        <td>21079</td>
        <td>The Life of Napoleon Bonaparte</td>
    </tr>
    <tr>
        <td>Salzwedel</td>
        <td>52.85435</td>
        <td>11.1525</td>
        <td>26577</td>
        <td>The Golden Bough (Vol. 1 of 2)</td>
    </tr>
    <tr>
        <td>Schoenebeck</td>
        <td>52.01682</td>
        <td>11.7307</td>
        <td>37227</td>
        <td>A Dictionary of Arts· Manufactures and Mines</td>
    </tr>
    <tr>
        <td>Seesen</td>
        <td>51.89095</td>
        <td>10.17847</td>
        <td>6590</td>
        <td>Great Violinists And Pianists</td>
    </tr>
    <tr>
        <td>Stassfurt</td>
        <td>51.85186</td>
        <td>11.58508</td>
        <td>9320</td>
        <td>An Elementary Study of Chemistry</td>
    </tr>
    <tr>
        <td>Tangermuende</td>
        <td>52.54463</td>
        <td>11.97647</td>
        <td>24495</td>
        <td>The Thirteenth</td>
    </tr>
    <tr>
        <td>Thale</td>
        <td>51.74861</td>
        <td>11.041</td>
        <td>26580</td>
        <td>Randolph Caldecott</td>
    </tr>
    <tr>
        <td>Uelzen</td>
        <td>52.96572</td>
        <td>10.56111</td>
        <td>20136</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 4· Slice 4</td>
    </tr>
    <tr>
        <td>Wanzleben</td>
        <td>52.06087</td>
        <td>11.4408</td>
        <td>26823</td>
        <td>The Golden Bough (Vol. 2 of 2)</td>
    </tr>
    <tr>
        <td>Wernigerode</td>
        <td>51.83652</td>
        <td>10.78216</td>
        <td>34866</td>
        <td>Equinoctial Regions of America V2</td>
    </tr>
    <tr>
        <td>Wittenberge</td>
        <td>53.00543</td>
        <td>11.75032</td>
        <td>20007</td>
        <td>Pharos· The Egyptian</td>
    </tr>
    <tr>
        <td>Wittingen</td>
        <td>52.72694</td>
        <td>10.73613</td>
        <td>29606</td>
        <td>Plant Lore· Legends· and Lyrics</td>
    </tr>
    <tr>
        <td>Wolfenbuettel</td>
        <td>52.16442</td>
        <td>10.54095</td>
        <td>20259</td>
        <td>Bartholomew Sastrow</td>
    </tr>
    <tr>
        <td>Wolfsburg</td>
        <td>52.42452</td>
        <td>10.7815</td>
        <td>32359</td>
        <td>The Lion of the North</td>
    </tr>
    <tr>
        <td>Wusterhausen</td>
        <td>52.8912</td>
        <td>12.46021</td>
        <td>9522</td>
        <td>History of Friedrich II. of Prussia· Vol. IX. (of XXI.)</td>
    </tr>
    <tr>
        <td>Zerbst</td>
        <td>51.9662</td>
        <td>12.08517</td>
        <td>25387</td>
        <td>The Life of Philip Melanchthon</td>
    </tr>
</table>




```python
%%sql
select distinct on (cities.name) cities.name, cities.latitude, cities.longitude, books.id, books.title from cities
join mentions on (cities.id = mentions.cityid)
join books on (mentions.bookid = books.id)
where earth_box(ll_to_earth(52.38, 11.47), 50000*1.6) @> ll_to_earth(latitude, longitude)
and earth_distance(ll_to_earth(52.38, 11.47), ll_to_earth(latitude, longitude)) < 50000*1.6;
```

    35 rows affected.





<table>
    <tr>
        <th>name</th>
        <th>latitude</th>
        <th>longitude</th>
        <th>id</th>
        <th>title</th>
    </tr>
    <tr>
        <td>Aschersleben</td>
        <td>51.75742</td>
        <td>11.46084</td>
        <td>20197</td>
        <td>Pictures of German Life in the XVIIIth and XIXth Centuries· Vol. I.</td>
    </tr>
    <tr>
        <td>Ballenstedt</td>
        <td>51.719</td>
        <td>11.23265</td>
        <td>23448</td>
        <td>Letters of Franz Liszt· Volume 2:  From Rome to the End</td>
    </tr>
    <tr>
        <td>Bernburg</td>
        <td>51.79464</td>
        <td>11.7401</td>
        <td>20828</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 3· Slice 5</td>
    </tr>
    <tr>
        <td>Braunschweig</td>
        <td>52.26594</td>
        <td>10.52673</td>
        <td>25937</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 14· Slice 2</td>
    </tr>
    <tr>
        <td>Calbe</td>
        <td>51.90668</td>
        <td>11.77478</td>
        <td>27471</td>
        <td>The Golden Bough (Third Edition· Vol. 7 of 12)</td>
    </tr>
    <tr>
        <td>Gardelegen</td>
        <td>52.5252</td>
        <td>11.39523</td>
        <td>27471</td>
        <td>The Golden Bough (Third Edition· Vol. 7 of 12)</td>
    </tr>
    <tr>
        <td>Genthin</td>
        <td>52.40668</td>
        <td>12.1592</td>
        <td>18539</td>
        <td>Tales from the German</td>
    </tr>
    <tr>
        <td>Gommern</td>
        <td>52.07391</td>
        <td>11.82297</td>
        <td>29713</td>
        <td>The Golden Bough: A Study in Magic and Religion (Third Edition· Vol.</td>
    </tr>
    <tr>
        <td>Halberstadt</td>
        <td>51.89562</td>
        <td>11.05622</td>
        <td>24247</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 12· Slice 7</td>
    </tr>
    <tr>
        <td>Havelberg</td>
        <td>52.83088</td>
        <td>12.07552</td>
        <td>3791</td>
        <td>The Life of Napoleon I (Volume 2 of 2)</td>
    </tr>
    <tr>
        <td>Helmstedt</td>
        <td>52.2279</td>
        <td>11.00985</td>
        <td>28485</td>
        <td>The Criminal Prosecution and Capital Punishment of Animals</td>
    </tr>
    <tr>
        <td>Ilsenburg</td>
        <td>51.86695</td>
        <td>10.67817</td>
        <td>7877</td>
        <td>Christmas in Ritual and Tradition· Christian and Pagan</td>
    </tr>
    <tr>
        <td>Kloetze</td>
        <td>52.62725</td>
        <td>11.16424</td>
        <td>22852</td>
        <td>The Vulture Maiden</td>
    </tr>
    <tr>
        <td>Koethen</td>
        <td>51.75185</td>
        <td>11.97093</td>
        <td>16952</td>
        <td>The Great Events by Famous Historians· v. 13</td>
    </tr>
    <tr>
        <td>Lehre</td>
        <td>52.33333</td>
        <td>10.66667</td>
        <td>23880</td>
        <td>A Literary History of the Arabs</td>
    </tr>
    <tr>
        <td>Luechow</td>
        <td>52.96811</td>
        <td>11.15397</td>
        <td>23646</td>
        <td>For Sceptre and Crown· Vol. I (of II)</td>
    </tr>
    <tr>
        <td>Magdeburg</td>
        <td>52.12773</td>
        <td>11.62916</td>
        <td>19599</td>
        <td>Famous Singers of To-day and Yesterday</td>
    </tr>
    <tr>
        <td>Meinersen</td>
        <td>52.47436</td>
        <td>10.35247</td>
        <td>2003</td>
        <td>Balder The Beautiful· Vol. I.</td>
    </tr>
    <tr>
        <td>Moeckern</td>
        <td>52.14099</td>
        <td>11.95203</td>
        <td>14866</td>
        <td>Principles Of Political Economy</td>
    </tr>
    <tr>
        <td>Osterburg</td>
        <td>52.78721</td>
        <td>11.75297</td>
        <td>20814</td>
        <td>A Biographical Dictionary of Freethinkers of All Ages and Nations</td>
    </tr>
    <tr>
        <td>Quedlinburg</td>
        <td>51.78843</td>
        <td>11.15006</td>
        <td>29109</td>
        <td>The Every Day Book of History and Chronology</td>
    </tr>
    <tr>
        <td>Rathenow</td>
        <td>52.60659</td>
        <td>12.33696</td>
        <td>30710</td>
        <td>Louis Spohr&#x27;s Autobiography</td>
    </tr>
    <tr>
        <td>Rosslau</td>
        <td>51.88736</td>
        <td>12.24192</td>
        <td>21300</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 9· Slice 2</td>
    </tr>
    <tr>
        <td>Salzwedel</td>
        <td>52.85435</td>
        <td>11.1525</td>
        <td>26577</td>
        <td>The Golden Bough (Vol. 1 of 2)</td>
    </tr>
    <tr>
        <td>Schoenebeck</td>
        <td>52.01682</td>
        <td>11.7307</td>
        <td>14556</td>
        <td>The Life of Trust: Being a Narrative of the Lord&#x27;s Dealings With George Mueller</td>
    </tr>
    <tr>
        <td>Stassfurt</td>
        <td>51.85186</td>
        <td>11.58508</td>
        <td>37013</td>
        <td>City of Endless Night</td>
    </tr>
    <tr>
        <td>Tangermuende</td>
        <td>52.54463</td>
        <td>11.97647</td>
        <td>24495</td>
        <td>The Thirteenth</td>
    </tr>
    <tr>
        <td>Thale</td>
        <td>51.74861</td>
        <td>11.041</td>
        <td>1374</td>
        <td>Views a-foot</td>
    </tr>
    <tr>
        <td>Wanzleben</td>
        <td>52.06087</td>
        <td>11.4408</td>
        <td>27471</td>
        <td>The Golden Bough (Third Edition· Vol. 7 of 12)</td>
    </tr>
    <tr>
        <td>Wernigerode</td>
        <td>51.83652</td>
        <td>10.78216</td>
        <td>25072</td>
        <td>Encyclopaedia Britannica· 11th Edition· Volume 13· Slice 4</td>
    </tr>
    <tr>
        <td>Wittenberge</td>
        <td>53.00543</td>
        <td>11.75032</td>
        <td>20007</td>
        <td>Pharos· The Egyptian</td>
    </tr>
    <tr>
        <td>Wittingen</td>
        <td>52.72694</td>
        <td>10.73613</td>
        <td>29606</td>
        <td>Plant Lore· Legends· and Lyrics</td>
    </tr>
    <tr>
        <td>Wolfenbuettel</td>
        <td>52.16442</td>
        <td>10.54095</td>
        <td>7739</td>
        <td>The Great Book-Collectors</td>
    </tr>
    <tr>
        <td>Wolfsburg</td>
        <td>52.42452</td>
        <td>10.7815</td>
        <td>32359</td>
        <td>The Lion of the North</td>
    </tr>
    <tr>
        <td>Zerbst</td>
        <td>51.9662</td>
        <td>12.08517</td>
        <td>17524</td>
        <td>The Count&#x27;s Chauffeur</td>
    </tr>
</table>




```python
%%sql
select earth_distance(ll_to_earth(52.24856185913086, 11.629449844360352), ll_to_earth(52.38, 11.47))
```

    1 rows affected.





<table>
    <tr>
        <th>earth_distance</th>
    </tr>
    <tr>
        <td>18216.2614555625</td>
    </tr>
</table>




```python
%%sql
select * from cities
where name like 'Wolmirstedt';
```

    1 rows affected.





<table>
    <tr>
        <th>id</th>
        <th>name</th>
        <th>latitude</th>
        <th>longitude</th>
        <th>cc</th>
        <th>population</th>
    </tr>
    <tr>
        <td>2806342</td>
        <td>Wolmirstedt</td>
        <td>52.24856</td>
        <td>11.62945</td>
        <td>DE</td>
        <td>10860</td>
    </tr>
</table>


