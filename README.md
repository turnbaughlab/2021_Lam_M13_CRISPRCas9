# 2021_Lam_M13_CRISPRCas9

**Author**: Kathy N. Lam\
**Updated**: April 12, 2021

The following code, scripts, and data are provided for analyses performed in Lam *et al.*, 2021. Phage-delivered CRISPR-Cas9 for strain-specific depletion and
genomic deletions in the gut microbiota. [[bioRxiv version]](https://www.biorxiv.org/content/10.1101/2020.07.09.193847v1.full)

## Flow cytometry

Flow cytometry data were analyzed using R.

- [[R notebook]](https://htmlpreview.github.io/?) Flow cytometry for in vitro: *E. coli sfgfp* vs *E. coli mcherry* with GFPT-M13 at 8h
- [[R notebook]](https://htmlpreview.github.io/?) Flow cytometry for in vitro: *E. coli sfgfp* vs *E. coli mcherry* with GFPT-M13 at 8h vs 24h
- [[R notebook]](https://htmlpreview.github.io/?https://github.com/turnbaughlab/2021_Lam_M13_CRISPRCas9/blob/main/2020-01-13_flow_exp17.html) Flow cytometry for mouse exp17: *E. coli sfgfp* vs *E. coli mcherry* with GFPT-M13
- [[R notebook]](https://htmlpreview.github.io/?) Flow cytometry for mouse exp19: *E. coli sfgfp mcherry* with GFPT-M13


## 16S rRNA gene sequencing

Sequencing reads were processed in a QIIME2 pipeline as described and analyzed in R.

- [[R notebook]](https://htmlpreview.github.io/?) 16S rRNA gene sequencing analysis for mouse exp11: streptomycin treatment


## Genomic deletions

Sequencing reads were processed and compared to reference genomes.

- [[bash script]]() Read depth using bowtie2 and samtools 
- [[bash script]]() Deletion prediction using breseq   

## Reference genome assemblies

Complete reference genomes were generated using Nanopore/Illumina hybrid assembly as described.

- [[fasta file]]() *E. coli* W1655 F+ (ATCC 23590 / KL68)
- [[fasta file]]() *E. coli* W1655 F+ *sfgfp* (KL114)
- [[fasta file]]() *E. coli* W1655 F+ *sfgfp mcherry* (KL204)
