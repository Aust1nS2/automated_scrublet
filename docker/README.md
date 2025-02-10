Docker image compiled in the following manner:
```
cd /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet
docker build -t austins2/automated_scrublet:v20250210 . -f docker/Dockerfile
docker push austins2/automated_scrublet:v20250210
```
Docker image tested successfully as follows:
```
# scrublet-RNA-auto.sh
cd /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/inputs/RNA/
ln -s /diskmnt/Projects/Users/austins2/pdac/cellranger/primary/2022-04-18/HT270P1-S1H2Fc2A2N1Bmn1_1 .
cd /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/RNA
docker run \
-v /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet:/diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet \
-v /diskmnt/Projects/Users/austins2/pdac/cellranger/primary/2022-04-18/HT270P1-S1H2Fc2A2N1Bmn1_1:/diskmnt/Projects/Users/austins2/pdac/cellranger/primary/2022-04-18/HT270P1-S1H2Fc2A2N1Bmn1_1 \
austins2/automated_scrublet:v20250210 /bin/bash /code/scripts/scrublet-RNA-auto.sh \
/code/scripts \
/diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/inputs/RNA

# scrublet-ATAC-auto.sh
cd /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/inputs/ATAC/
ln -s /diskmnt/Projects/Users/austins2/pdac/cellranger/primary/2022-04-18/HT270P1-S1H2Fc2A2N1Bmn1_1 .
cd /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/ATAC
docker run \
-v /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet:/diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet \
-v /diskmnt/Projects/Users/austins2/pdac/cellranger/primary/2022-04-18/HT270P1-S1H2Fc2A2N1Bmn1_1:/diskmnt/Projects/Users/austins2/pdac/cellranger/primary/2022-04-18/HT270P1-S1H2Fc2A2N1Bmn1_1 \
austins2/automated_scrublet:v20250210 /bin/bash /code/scripts/scrublet-ATAC-auto.sh \
/code/scripts \
/diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/inputs/ATAC

# scrublet-auto-combining.sh
cd /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/combined
docker run \
-v /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet:/diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet \
austins2/automated_scrublet:v20250210 /bin/bash /code/scripts/scrublet-auto-combining.sh \
/code/scripts \
/diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/inputs/ATAC

# scrublet-ATAC-only-auto.sh
cd /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/inputs/ATAC-only/
ln -s /diskmnt/Projects/Users/austins2/pancan_ATAC/separate-cellranger-test/ATAC/CPT1541DU-S1 .
cd /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/ATAC-only
docker run \
-v /diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet:/diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet \
-v /diskmnt/Projects/Users/austins2/pancan_ATAC/separate-cellranger-test/ATAC/CPT1541DU-S1:/diskmnt/Projects/Users/austins2/pancan_ATAC/separate-cellranger-test/ATAC/CPT1541DU-S1 \
austins2/automated_scrublet:v20250210 /bin/bash /code/scripts/scrublet-ATAC-auto.sh \
/code/scripts \
/diskmnt/Projects/Users/austins2/tools/docker_images/micromamba_scrublet/automated_scrublet/test/v20250210/inputs/ATAC
```

