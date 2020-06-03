
## Download
ftp = 'ftp://ftp.ddbj.nig.ac.jp/ddbj_database/dra/fastq/SRA232/SRA232588'
srxs = 'SRX844499 SRX844500 SRX844501 SRX844502 SRX844503 SRX844504 SRX844505 SRX844508'.split()[-2:]
srrs = 'SRR1761288 SRR1761289 SRR1761290 SRR1761291 SRR1761292 SRR1761293 SRR1761294 SRR1761297'.split()[-2:]
links = { srr:'%s/%s/%s.fastq.bz2'%(ftp,srx,srr) for srx,srr in zip(srxs, srrs) }


## Samples
SAMPLES = [ 'eif3a_rep1', 'eif3a_rep2', 'eif3a_rep3', 'eif3b_rep1', 'eif3b_rep2', 'eif3b_rep3',
            'eif3d_rep1', 'eif3g_rep1' ][-2:]
# change name manually

## Preprocessing
MINQUAL = 25
MINQUALIFIED = 80
ADAPT3 = 'TGGAATTCTCGGGTGCCAAGG'
TRIMS = { 'rep1':12, 'rep2':0, 'rep3':0 }
MINLEN = 10

## Mapping
NCORE = 4
REFERENCE = 'references/L1_BTG1'
MULTIMAP = 2
MAXMM = 3
MAXSC = 0
SCOREFUNC = 'L,%s,%s' % (-2*MAXSC-6*MAXMM, 2)


rule all: 
    input: #expand('rawdata/{srr}.fastq.gz', srr=srrs),
           #expand('data/{sample}.fa.gz', sample=SAMPLES),
           expand('alignments/{sample}_10.bam.bai', sample=SAMPLES),
           expand('alignments/{sample}_10.txt.gz', sample=SAMPLES)

############################## Download ##############################
rule download:
    output: 'rawdata/{srr}.fastq.bz2'
    run:
        link = links[wildcards.srr]
        shell('wget {link} -O {output}')
        #shell('fastq-dump --gzip -O rawdata {srr}')


rule bz2_to_fastq:
    input: 'rawdata/{srr}.fastq.bz2'
    output: 'rawdata/{srr}.fastq.gz'
    shell: 'bzcat {input} | gzip -c - > {output}'


############################ Preprocessing ############################
rule qc:
    input: 'rawdata/{sample}.fastq.gz'
    output: 'qc/{sample}.fa.gz'
    shell: 'zcat {input} | \
            fastq_quality_filter -Q33 -q {MINQUAL} -p {MINQUALIFIED} - | \
            fastq_to_fasta -Q33 -n - | \
            gzip -c - > {output}'


rule collapse: 
    input: 'qc/{sample}.fa.gz'
    output: 'coll/{sample}.fa.gz'
    shell: 'zcat {input} | \
            fastx_collapser -Q33 - | \
            gzip -c - > {output}'


rule cutadapt: 
    input: 'coll/{sample}.fa.gz'
    output: 'data/{sample}_10.fa.gz'
    run:
        trim = TRIMS[wildcards.sample.split('_')[1]]
        shell('zcat {input} | \
               cutadapt -a {ADAPT3} -u {trim} -m {MINLEN} - | \
               gzip -c - > {output}')


############################## Mapping ##############################
rule align:
    input: 'data/{sample}_10.fa.gz'
    output: temp('alignments/{sample}_10.unsorted.bam')
    shell: 'bowtie2 -p {NCORE} -f --local --norc -x {REFERENCE} -U {input} --score-min {SCOREFUNC} | \
            samtools view -bS - > {output}'


rule sort_bam:
    input: 'alignments/{sample, [^.]+}_10.unsorted.bam'
    output: 'alignments/{sample, [^.]+}_10.bam'
    run:
        tmp = wildcards.sample+'_tmp'
        shell('samtools sort -@ {NCORE} -O bam -o {output} -T {tmp} {input}')


rule index_bam:
    input: 'alignments/{sample, [^.]+}_10.bam'
    output: 'alignments/{sample, [^.]+}_10.bam.bai'
    shell: 'samtools index -@ {NCORE} {input}'


rule select_mapped:
    input: 'alignments/{sample, [^.]+}_10.bam'
    output: 'alignments/{sample, [^.]+}_10.txt.gz'
    shell: 'samtools view {input} | \
            awk "{{if (\$2==0) {{print \$3,\$4,\$6,\$8}}}}" - | \
            gzip -c - > {output}'

# vim: et syntax=snakemake
