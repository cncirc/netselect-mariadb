# netselect-mariadb

Utility that can choose the best MariaDB mirror by downloading the full mirror list and using netselect to find the fastest/closest one

## Requirements

`netselect` must be installed before running the script:

```bash
apt-get install -y netselect
```

## Usage

`sudo netselect-mariadb <debian_release> <mariadb_version>`


Example:

```bash
sudo netselect-mariadb.pl stretch 10.2
```

Example output:

```
deb [arch=amd64,i386] http://mirrors.evowise.com/mariadb/repo/10.2/debian jessie main
deb-src http://mirrors.evowise.com/mariadb/repo/10.2/debian jessie main
```
