process GET_IMAGES {
    label 'bash_container'

    input:
    path nextflowConfig

    output:
    path("images.json"), emit:json

    shell:
    '''
    IMAGES=$(grep -E "container\s?=" !{nextflowConfig} \
                | sort -u \
                | sed -r "s/\s+container\s?=\s?'(.+)'/\\1/")

    BASH=$(grep network-multitool <<< $IMAGES)
    GIT=$(grep git <<< $IMAGES)
    PYTHON=$(grep python <<< $IMAGES)
    FASTP=$(grep fastp <<< $IMAGES)
    UNICYCLER=$(grep unicycler <<< $IMAGES)
    SHOVILL=$(grep shovill <<< $IMAGES)
    QUAST=$(grep quast <<< $IMAGES)
    BWA=$(grep bwa <<< $IMAGES)
    SAMTOOLS=$(grep samtools <<< $IMAGES)
    BCFTOOLS=$(grep bcftools <<< $IMAGES)
    POPPUNK=$(grep poppunk <<< $IMAGES)
    SPN_PBP_AMR=$(grep spn-pbp-amr <<< $IMAGES)
    AMRSEARCH=$(grep amrsearch <<< $IMAGES)
    MLST=$(grep mlst <<< $IMAGES)
    KRAKEN2=$(grep kraken2 <<< $IMAGES)
    SEROBA=$(grep seroba <<< $IMAGES)

    add_container () {
        echo $(jq -n --arg container $1 '.container = $container')
    }

    jq -n \
        --argjson bash "$(add_container $BASH)" \
        --argjson git "$(add_container $GIT)" \
        --argjson python "$(add_container $PYTHON)" \
        --argjson fastp "$(add_container $FASTP)" \
        --argjson unicycler "$(add_container $UNICYCLER)" \
        --argjson shovill "$(add_container $SHOVILL)" \
        --argjson quast "$(add_container $QUAST)" \
        --argjson bwa "$(add_container $BWA)" \
        --argjson samtools "$(add_container $SAMTOOLS)" \
        --argjson bcftools "$(add_container $BCFTOOLS)" \
        --argjson poppunk "$(add_container $POPPUNK)" \
        --argjson spn_pbp_amr "$(add_container $SPN_PBP_AMR)" \
        --argjson amrsearch "$(add_container $AMRSEARCH)" \
        --argjson mlst "$(add_container $MLST)" \
        --argjson kraken2 "$(add_container $KRAKEN2)" \
        --argjson seroba "$(add_container $SEROBA)" \
        '$ARGS.named' > images.json
    '''
}

process COMBINE_INFO {
    label 'bash_container'

    input:
    val pipeline_version
    path(images)
    val(git_version)
    val(python_version)
    val(fastp_version)
    val(unicycler_version)
    val(shovill_version)
    val(quast_version)
    val(bwa_version)
    val(samtools_version)
    val(bcftools_version)
    val(poppunk_version)
    val(mlst_version)
    val(kraken2_version)
    val(seroba_version)

    output:
    path("result.json"), emit: json

    shell:
    '''
    cp !{images} working.json

    add_version () {
        jq --arg entry $1 --arg version \"$2\" '.[$entry] += {"version": $version}' working.json > tmp.json && mv tmp.json working.json
    }

    add_version pipeline "!{pipeline_version}"

    add_version git "!{git_version}"
    add_version python "!{python_version}"
    add_version fastp "!{fastp_version}"
    add_version unicycler "!{unicycler_version}"
    add_version shovill "!{shovill_version}"
    add_version quast "!{quast_version}"
    add_version bwa "!{bwa_version}"
    add_version samtools "!{samtools_version}"
    add_version bcftools "!{bcftools_version}"
    add_version poppunk "!{poppunk_version}"
    add_version mlst "!{mlst_version}"
    add_version kraken2 "!{kraken2_version}"
    add_version seroba "!{seroba_version}"

    mv working.json result.json
    '''
}

process GET_GIT_VERSION {
    label 'git_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(git -v | sed -r "s/.*\s(.+)/\\1/")
    '''
}

process GET_PYTHON_VERSION {
    label 'python_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(python --version | sed -r "s/.*\s(.+)/\\1/")
    '''
}

process GET_FASTP_VERSION {
    label 'fastp_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(fastp -v 2>&1 | sed -r "s/.*\s(.+)/\\1/")
    '''
}

process GET_UNICYCLER_VERSION {
    label 'unicycler_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(unicycler --version | sed -r "s/.*\sv(.+)/\\1/")
    '''
}

process GET_SHOVILL_VERSION {
    label 'shovill_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(shovill -v | sed -r "s/.*\s(.+)/\\1/")
    '''
}

process GET_QUAST_VERSION {
    label 'quast_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(quast.py -v | sed -r "s/.*\sv(.+)/\\1/")
    '''
}

process GET_BWA_VERSION {
    label 'bwa_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(bwa 2>&1 | grep Version | sed -r "s/.*:\s(.+)/\\1/")
    '''
}

process GET_SAMTOOLS_VERSION {
    label 'samtools_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(samtools 2>&1 | grep Version | sed -r "s/.*:\s(.+)/\\1/")
    '''
}

process GET_BCFTOOLS_VERSION {
    label 'bcftools_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(bcftools 2>&1 | grep Version | sed -r "s/.*:\s(.+)/\\1/")
    '''
}

process GET_POPPUNK_VERSION {
    label 'poppunk_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(poppunk --version | sed -r "s/.*\s(.+)/\\1/")
    '''
}

process GET_MLST_VERSION {
    label 'mlst_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(mlst -v | sed -r "s/.*\s(.+)/\\1/")
    '''
}

process GET_KRAKEN2_VERSION {
    label 'kraken2_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(kraken2 -v | grep version | sed -r "s/.*\s(.+)/\\1/")
    '''
}

process GET_SEROBA_VERSION {
    label 'seroba_container'

    output:
    env VERSION

    shell:
    '''
    VERSION=$(seroba version)
    '''
}

