## Fastx Toolkit
Fastx-toolkit version 0.0.13 requires libgtextutils-0.6 (available here for download)
A recent g++ compiler (tested with GNU G++ 4.1.2 and later).
The fasta_clipping_histogram tool requires two perl modules: PerlIO::gzip and GD::Graph::bars.
The fastx_barcode_splitter tool requires GNU sed.
The fastq_quality_boxplot tool requires gnuplot version 4.2 or newer.
For download and detailed instructions, click http://hannonlab.cshl.edu/fastx_toolkit/download.html.

## cutadapt
Cutadapt installation requires this software to be installed:
- Python 3.4 or newer
- Possibly a C compiler. For Linux, Cutadapt packages are provided as so-called “wheels” (.whl files) which come pre-compiled.
- Under Ubuntu, you may need to install the packages build-essential and python3-dev to get a C compiler.
For dowload and detailed manuals, click https://cutadapt.readthedocs.io/en/stable/installation.html.

## bowtie2
| Operating System	| Sync Package List	| Search | Install |
|---|---|---|---|
|Ubuntu, Mint, Debian|	apt-get update	|apt-cache search tbb	|apt-get install libtbb-dev|
|Fedora, CentOS|	yum check-update	|yum search tbb	|yum install tbb-devel.x86_64|
|Arch|	packman -Sy	|pacman -Ss tbb	|pacman -S extra/intel-tbb|
|Gentoo|	emerge –sync	|emerge –search tbb	|emerge dev-cpp/tbb|
|macOS|	brew update|	brew search tbb	|brew install tbb|
|FreeBSD|	pkg update	|pkg search tbb	|pkg install tbb-2019.1|

For download and detailed manual, click http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml. 
