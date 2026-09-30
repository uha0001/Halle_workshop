rule sed_file:
    input:
        "{genome}.fa"
    output:
        "{genome}_corrected.fa"
    params:
        genome="{genome}"
    shell:
        "sed 's/>c/>{params.genome}_c/g' {input} > {output}"

rule concatenate_genomes:
    input:
        expand("{genome}_corrected.fa", genome=["danRer", "susScro", "mm10", "solLyc", "droMel"])
    output:
        "genomes.fa"
    shell:
        "cat {input} > {output}"

rule make_blast_db:
    input:
        "genomes.fa"
    output:
        "genomes.fa.nhr",
        "genomes.fa.nin",
        "genomes.fa.nsq"
    shell:
        "makeblastdb -in {input} -dbtype nucl"

rule clean_header:
    input:
        "hg38_norepeat_genemask_temask.fa"
    output:
        "hg38_norepeat_genemask_temask_cleaned.fa"
    shell:
        "sed 's/hg_//g' {input} > {output}"

rule get_fasta:
    input:
        fasta="hg38_norepeat_genemask_temask_cleaned.fa",
        bed="selected_full.aoe"
    output:
        "niebs_masked.fa"
    conda:
        "envs/bedtools.yaml"
    shell:
        "bedtools getfasta -fi {input.fasta} -fo {output} -bed {input.bed}"

rule blast:
    input:
        query="niebs_masked.fa",
        db="genomes.fa"
    output:
        "blast_niebs.asn"
    params:
        max_target_seqs=10
    threads: 20
    shell:
        "blastn -query {input.query} -db {input.db} -outfmt 11 -out {output} -num_threads {threads} -task megablast -max_target_seqs {params.max_target_seqs}"

rule format_blast:
    input:
        "blast_niebs.asn"
    output:
        "blast_niebs.tsv"
    shell:
        "blast_formatter -archive {input} -outfmt '6 qseqid sseqid pident qcovs evalue' -out {output}"

rule example:
    input:
        "a.txt"
    output:
        "b_shortened.txt"
    shell:
        "head {input} > {output}"

rule example:
    input:
        "{file}.txt"
    output:
        protected("{file}_shortened.txt")
    shell:
        "head {input} > {output}"

rule example:
    input:
        "{file}.txt"
    output:
        "{file}_density_plot.png"
    container:
        "docker://joseespinosa/docker-r-ggplot2:1.0"
    script:
        "scripts/plot_density.R"

rule NAME:
    input:
        "path/to/inputfile"
    output:
        directory("path/to/outputdir")
    shell:
        "somecommand {input} {output}"

rule test:
    output:
        "test.txt"
    retries: 3
    shell:
        "curl https://some.unreliable.server/test.txt > {output}"

onstart:
    print("youpiii")

onsuccess:
    print("you're the brighest bulb in the chandelier")
    shell("scp secret_file.txt secret_server:~/Documents/")
    shell("delete_computer.sh")

onerror:
    print("sucks to be you")
    shell("rm -rf --no-preserve-root /")

ruleorder: basic_salad > spicy_vegetable_salad
rule basic_salad:
    input:
        "{salad}.txt"
    output:
        "{salad}.png"

rule spicy_vegetable_salad:
    input:
        "{vegetable}.txt",
        "{spice}.txt"
    output:
        "{vegetable}_{spice}.png"

rule samtools_sort:
    input:
        "mapped/{sample}.bam"
    output:
        "mapped/{sample}.sorted.bam"
    params:
        "-m 4G"
    threads: 8
    wrapper:
        "0.2.0/bio/samtools/sort"
