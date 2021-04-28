 
/*
 * Defines some parameters in order to specify the refence genomes
 * and read pairs by using the command line options
 */
params.reads = "$baseDir/data/ggal/*_{1,2}.fq"
params.annot = "$baseDir/data/ggal/ggal_1_48850000_49020000.bed.gff"
params.genome = "$baseDir/data/ggal/ggal_1_48850000_49020000.Ggal71.500bpflank.fa"
params.outdir = 'results'

log.info """\
         TFG   P I P E L I N E    
         =============================
         genome: ${params.genome}
         annot : ${params.annot}
         reads : ${params.reads}
         outdir: ${params.outdir}
         """
         .stripIndent()
 
/*
 * Create the `read_pairs_ch` channel that emits tuples containing three elements:
 * the pair ID, the first read-pair file and the second read-pair file 
 */
Channel
    .fromFilePairs( params.reads )
    .ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
    .into { read_pairs_ch; read_pairs_fastqc }
    
process fastqc {
	tag "$pair_id"
	
	input:
	set val(name), file(reads) from read_pairs_fastqc
	
	output:
	file "*_fastqc.{zip,html}" into fastqc_results
	
	script:
	"""
	fastqc -q $reads
	"""
}
	
 
/*
 * Step 1. Builds the genome index required by the mapping process
 */
process buildIndex {
    tag "$genome.baseName"
    
    input:
    path genome from params.genome
     
    output:
    path 'genome.index*' into index_ch
       
    """
    bowtie2-build --threads ${task.cpus} ${genome} genome.index
    """
}
 
/*
 * Step 2. Maps each read-pair by using Tophat2 mapper tool
 */
process mapping {
    tag "$pair_id"
     
    input:
    path genome from params.genome 
    path annot from params.annot
    path index from index_ch
    tuple val(pair_id), path(reads) from read_pairs_ch
 
    output:
    set pair_id, "accepted_hits.bam" into bam_ch
    file "tophat_*" into tophat_results
 
    """
    tophat -p ${task.cpus} --GTF $annot genome.index $reads
    mv tophat_out/accepted_hits.bam .
    """
}
  
/*
 * Step 3. Assembles the transcript by using the "cufflinks" tool
 */
process makeTranscript {
    tag "$pair_id"
    publishDir params.outdir, mode: 'copy'  
       
    input:
    path annot from params.annot
    tuple val(pair_id), path(bam_file) from bam_ch
     
    output:
    tuple val(pair_id), path('transcript_*.gtf')
 
    """
    cufflinks --no-update-check -q -p $task.cpus -G $annot $bam_file
    mv transcripts.gtf transcript_${pair_id}.gtf
    """
}

process multiqc {
	publishDir "${params.outdir}/MultiQC", mode: 'copy'  
	
	input:
	file ("fastqc/*") from fastqc_results.collect().ifEmpty([])
	file ("tophat/tophat.out.*") from tophat_results.collect().ifEmpty([]) 
	
	output:
	file "multiqc_report.html" into multiqc_report
	file "*_data"
	
	script:
	"""
	multiqc .
	"""
}
 
workflow.onComplete { 
	log.info ( workflow.success ? "Done!" : "Oops .. something went wrong" )
}
