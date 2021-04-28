AII RNA-Seq pipeline
======================

Prueba de ejemplo para demostrar las ventajas de Docker
en la ejecución de workflows complejos de análisis genómico

How execute it
----------------

1) Instalar docker. Más en https://docs.docker.com/

2) Instalar Nextflow (version 20.01.0 o posterior)

    `curl -fsSL get.nextflow.io | bash`

3) Hacer pull de la imagen correspondiente: 

    `docker pull santiagomillan/tfg_pipeline:1.1`


4) Launch the pipeline execution: 

    `nextflow run main.nf -with-docker` 
    
    