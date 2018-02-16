

load_maps = function(h='hg19', m='mm10'){
    
    # Get gene lists
    hgenes = readLines(paste0('~/aviv/db/map_gene/', h, '_genes.txt'))
    mgenes = readLines(paste0('~/aviv/db/map_gene/', m, '_genes.txt'))
    
    # Get gene synonyms
    hsyn = paste0('~/aviv/db/map_gene/', h, '.gene_map.txt')
    hsyn = read.table(hsyn, row.names=1, sep='\t', stringsAsFactors=F, quote='', comment.char='')
    msyn = paste0('~/aviv/db/map_gene/', m, '.gene_map.txt')
    msyn = read.table(msyn, row.names=1, sep='\t', stringsAsFactors=F, quote='', comment.char='')
    
    # Get orthologs
    h2m = paste0('~/aviv/db/map_gene/orthologs.', h, '_to_', m, '.txt')
    h2m = read.table(h2m, sep='\t', stringsAsFactors=F, quote='', comment.char='', row.names=1)
    m2h = paste0('~/aviv/db/map_gene/orthologs.', m, '_to_', h, '.txt')
    m2h = read.table(m2h, sep='\t', stringsAsFactors=F, quote='', comment.char='', row.names=1)

    # Return maps
    return(list(h=h, m=m, hgenes=hgenes, mgenes=mgenes, hsyn=hsyn, msyn=msyn, h2m=h2m, m2h=m2h))
}


maps = load_maps()
list2env(maps, .GlobalEnv)


predict_organism = function(genes){
    if(sum(genes %in% hgenes) > sum(genes %in% mgenes)){
        return('human')
    }
    if(sum(genes %in% hgenes) < sum(genes %in% mgenes)){
        return('mouse')
    }
    return('unknown')
}


fix_names = function(names){
    names = toupper(names)
    names = gsub('[^a-zA-Z0-9]', '', names)
    return(names)
}


get_synonyms = function(genes, target='human'){
    genes = fix_names(genes)
    if(target == 'human'){genes = hsyn[genes,1]}
    if(target == 'mouse'){genes = msyn[genes,1]}
    unlist(strsplit(genes, ','))
}


get_orthologs = function(genes, source='mouse', target='human'){
    genes = get_synonyms(genes, target=source)
    genes = fix_names(genes)
    if(target == 'mouse'){ortho = h2m[genes,1]}
    if(target == 'human'){ortho = m2h[genes,1]}
    ortho = unlist(strsplit(ortho, ','))
    get_synonyms(ortho, target=target)
}


map_gene = function(genes, target='human', source='auto'){
    
    # predict source organism from gene list
    # --------------------------------------
    
    if(source == 'auto'){
        source = predict_organism(genes)
    }

    if(source == 'unknown'){
        cat(paste('\nmap_gene: unknown source organism, assuming source =', target, '\n'))
	source = target
    }

    # map genes using synonyms or orthologs
    # -------------------------------------
    
    if(source == target){
        get_synonyms(genes, target=target)
    } else {
        get_orthologs(genes, source=source, target=target)
    }

}
