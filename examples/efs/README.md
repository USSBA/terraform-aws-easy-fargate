# Easy Fargate with multiple EFS

If you check the logs after running the task once, you'll see something like:

```shell
+ tree /mnt
/mnt
|-- one_a
|-- one_b
`-- two
3 directories, 0 files
+ touch /mnt/one_a/foo-2020-12-28T19:54+00:00
+ tree /mnt
/mnt
|-- one_a
|   `-- foo-2020-12-28T19:54+00:00
|-- one_b
|   `-- foo-2020-12-28T19:54+00:00
`-- two
3 directories, 2 files
+ touch /mnt/one_b/bar-2020-12-28T19:54+00:00
+ tree /mnt
/mnt
|-- one_a
|   |-- bar-2020-12-28T19:54+00:00
|   `-- foo-2020-12-28T19:54+00:00
|-- one_b
|   |-- bar-2020-12-28T19:54+00:00
|   `-- foo-2020-12-28T19:54+00:00
`-- two
3 directories, 4 files
+ touch /mnt/two/baz-2020-12-28T19:54+00:00
+ tree /mnt
/mnt
|-- one_a
|   |-- bar-2020-12-28T19:54+00:00
|   `-- foo-2020-12-28T19:54+00:00
|-- one_b
|   |-- bar-2020-12-28T19:54+00:00
|   `-- foo-2020-12-28T19:54+00:00
`-- two
    `-- baz-2020-12-28T19:54+00:00
3 directories, 5 files
```

If you run it again (at least 1 minute later), the final tree will look like:

```shell
+ tree /mnt
/mnt
|-- one_a
|   |-- bar-2020-12-28T19:54+00:00
|   |-- bar-2020-12-28T19:57+00:00
|   |-- foo-2020-12-28T19:54+00:00
|   `-- foo-2020-12-28T19:57+00:00
|-- one_b
|   |-- bar-2020-12-28T19:54+00:00
|   |-- bar-2020-12-28T19:57+00:00
|   |-- foo-2020-12-28T19:54+00:00
|   `-- foo-2020-12-28T19:57+00:00
`-- two
    |-- baz-2020-12-28T19:54+00:00
    `-- baz-2020-12-28T19:57+00:00
```
