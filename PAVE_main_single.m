% select a peak first from the pks list(i.e., i=3)
pk = pave_atomcount(M,pks(i),settings,rep); %atomcount sp01 
pk = pave_junkremover(M,pk,settings,rep,adduct); %junkremover sp02
pk = pave_find_lowC(pk,settings,m);% - annotation of Low_C  sp03
pk = pave_identify_frag(M_CID,list,pk,settings); %CID fragment sp04
pk = pave_dbsearch(dbase,pk,settings); % -- dbsearch sp05
pk