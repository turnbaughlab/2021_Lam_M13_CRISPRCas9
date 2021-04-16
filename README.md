# 2021_Lam_M13_CRISPRCas9

**Author**: Kathy N. Lam\
**Updated**: April 15, 2021

The following code, scripts, and data are provided to support analyses performed in Lam *et al.*, 2021. Phage-delivered CRISPR-Cas9 for strain-specific depletion and
genomic deletions in the gut microbiota. [[bioRxiv version]](https://www.biorxiv.org/content/10.1101/2020.07.09.193847v1.full)

## Flow cytometry

Flow cytometry data, from in vitro bacterial cultures or from mouse stool resuspensions, were analyzed using R.

- [[R notebook]](https://htmlpreview.github.io/?https://github.com/turnbaughlab/2021_Lam_M13_CRISPRCas9/blob/main/2019-11-20_flow.html) Flow cytometry for in vitro: *E. coli sfgfp* vs *E. coli mcherry* with GFPT-M13 at 8h
- [[R notebook]](https://htmlpreview.github.io/?https://github.com/turnbaughlab/2021_Lam_M13_CRISPRCas9/blob/main/2019-11-05_flow.html) Flow cytometry for in vitro: *E. coli sfgfp* vs *E. coli mcherry* with GFPT-M13 at 8h vs 24h
- [[R notebook]](https://htmlpreview.github.io/?https://github.com/turnbaughlab/2021_Lam_M13_CRISPRCas9/blob/main/2020-01-13_flow_exp17.html) Flow cytometry for mouse exp17: *E. coli sfgfp* vs *E. coli mcherry* with GFPT-M13
- [[R notebook]](https://htmlpreview.github.io/?) Flow cytometry for mouse exp19: *E. coli sfgfp mcherry* with GFPT-M13


## 16S rRNA gene sequencing

Samples were processed using primary qPCR/secondary PCR, sequencing reads were processed in a QIIME2 pipeline and analyzed in R.

- [[R notebook]](https://htmlpreview.github.io/?https://github.com/turnbaughlab/2021_Lam_M13_CRISPRCas9/blob/main/2019-01-23_exp11_16S_analysis_v4.html) 16S rRNA gene sequencing analysis for mouse exp11: streptomycin treatment
- [[R notebook]](https://htmlpreview.github.io/?https://github.com/turnbaughlab/2021_Lam_M13_CRISPRCas9/blob/main/2019-02-04_exp11_estimate_bacterial_load_v2.html) Bacterial load estimation for mouse exp11: streptomycin treatment

## Genomic deletions

Sequencing reads derived from isolates were processed and compared to reference genomes on the UCSF computing cluster.

- [[bash script]]() Read depth using bowtie2 and samtools 
- [[bash script]]() Deletion prediction using breseq   


## Reference genome assemblies

Complete reference genomes were generated using Nanopore/Illumina hybrid assembly.

- [[fasta file]]() *E. coli* W1655 F+ (ATCC 23590 / KL68)
- [[fasta file]]() *E. coli* W1655 F+ *sfgfp* (KL114)
- [[fasta file]]() *E. coli* W1655 F+ *sfgfp mcherry* (KL204)

## CRISPR-Cas9 phagemid sequences

M13-compatible CRISPR-Cas9 phagemid vectors were constructed for GFPT-targeting or Non-targeting control.

- [[Genbank file]]() pCas9-GFPT-f1A (pKL100)
- [[Genbank file]]() pCas9-GFPT-f1B (pKL101)
- [[Genbank file]]() pCas9-NT-f1A (pKL102)
- [[Genbank file]]() pCas9-NT-f1B (pKL103)



