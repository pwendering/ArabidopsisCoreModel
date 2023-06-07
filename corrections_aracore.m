% Numerous corrections to the Arabidopsis core model
% The original model was published here:
%   https://doi.org/10.1104/pp.114.235358

% read original AraCore model
model = readCbModel(fullfile('AraCore_v1_0', 'AraCore_v1_0.xml'));

%% Yuan et al. (2016) Front. Plant Sci.
% https://doi.org/10.3389/fpls.2016.00537

% aconitase (EC 4.2.1.3) and fumarase (EC 4.2.1.2) must be reversible
model = changeRxnBounds(model, 'FumHA_m', -1000, 'l');
model = changeRxnBounds(model, 'cACNDHA_m', -1000, 'l');
model = changeRxnBounds(model, 'cACNHA_m', -1000, 'l');

%% von Bismarck et al. 2023

% add cytosolic HPR reaction (HPR2)
% https://doi.org/10.1104/pp.110.166538
model = addMetabolite(model, 'HPR[c]', 'metName', 'Hydroxypyruvate',...
    'metFormula', 'C3H3O4');
model = addReaction(model, 'Tr_HPR1',...
    'reactionName', 'Hydroxypyruvate transporter',...
    'reactionFormula', 'HPR[p] <=> HPR[c]');
model = addReaction(model, 'GCEADH_c',...
    'reactionName', 'GCEA dehydrogenase',...
    'reactionFormula', 'HPR[c] + NADPH[c] + H[c] -> GCEA[c] + NADP[c]',...
    'geneRule', 'AT1G79870');
model.rxnNotes(findRxnIDs(model, 'GCEADH_c')) = {'Reference: 10.1104/pp.110.166538; KEGG: R01388'};

% remove HPR1 from gene associations of chloroplastic HPR reaction
model = changeGeneAssociation(model, 'GCEADH_h', 'AT1G12550');
model.rxnNotes(findRxnIDs(model, 'GCEADH_h')) = {'Reference: 10.1104/pp.110.166538; KEGG: R01388'};

% remove GGT1(AT1G23310) and GGT2 (AT1G70580) from AlaTA_h gene association
% also remove AT1G17290 as the protein is predicted to be located in
% mitochondria
model = changeGeneAssociation(model, 'AlaTA_h', '');

% remove GGT1(AT1G23310) and GGT2 (AT1G70580) from GGAT_h gene association
% keep chloroplastic GGT reaction in the model
model = changeGeneAssociation(model, 'GGAT_h', '');

% update GPR rule for GlyHMT_c to remove mitochondria-localized gene
% products
% AT4G13930 and AT4G13890 are only lowly expressed in leaves, but highly
% expressed in roots (and flowers)
model = changeGeneAssociation(model, 'GlyHMT_c', 'AT4G13930 or AT4G13890');

%% Blätke & Bräutigam (2019) eLife
% https://doi.org/10.7554/eLife.49305

% add NAD-dependent malate dehydrogenases in all compartments,
% NADP-dependent malate dehydrogenase only in chloroplast
model = addReaction(model, 'MalDH2_m',...
    'reactionName', 'Mal dehydrogenase',...
    'reactionFormula', 'NAD[m] + Mal[m]   ->   Pyr[m] + CO2[m] + NADH[m]',...
    'geneRule', 'AT2G13560');

% replaces MalDH2NADP_h, which had two cytosolic gene products associated
model = addReaction(model, 'MalDH4_h',...
    'reactionName', 'Mal dehydrogenase',...
    'reactionFormula', 'NADP[h] + Mal[h]   ->   NADPH[h] + CO2[h] + Pyr[h]',...
    'geneRule', 'AT1G79750');
model = removeRxns(model, {'MalDH2NADP_h'});

% remove cytosolic reactions associated with AT5G58330 (chloroplast-localized)
model = removeRxns(model, {'MalDH3_c', 'MalDH3_m'});

% add cyclic electron flow
model = addReaction(model, 'NDC1_1_h',...
    'reactionName', 'Alternative NAD(P)H-ubiquinone oxidoreductase C1',...
    'reactionFormula', 'PQ[h] + H[h] + NADH[h]   ->   PQH2[h] + NAD[h]',...
    'geneRule', 'AT5G08740');
model.rxnNotes(findRxnIDs(model, 'NDC1_1_h')) = {'Reference: 10.1007/s11120-016-0227-0'};
model = addReaction(model, 'NDC1_2_h',...
    'reactionName', 'Alternative NAD(P)H-ubiquinone oxidoreductase C1',...
    'reactionFormula', 'PQ[h] + H[h] + NADPH[h]   ->   PQH2[h] + NADP[h]',...
    'geneRule', 'AT5G08740');
model.rxnNotes(findRxnIDs(model, 'NDC1_2_h')) = {'Reference: 10.1007/s11120-016-0227-0'};

% At5g58260     subunit N
% At4g37925     subunit M
% At5g21430     subunit U
% At4g23890     subunit S
% At1g74880     subunit O
% At1g70760     subunit L
% At4g09350     subunit T
% AtCg01110     subunit H
% AtCg01070     subunit 4L
% AtCg00430     subunit K
% AtCg01090     subunit I
% AtCg00890     subunit 2A
% AtCg00440     subunit 3
% AtCg01080     subunit 6
% AtCg01010     subunit 5
% AtCg00420     subunit J
% AtCg01050     chain 4
% AtCg01100     subunit 1
% AtCg01250     subunit 2B (not contained in GPR above)
% AT1G15980     subunit B1
% AT3G16250     subunit B3
% AT1G18730     subunit B4
% AT5G43750     subunit B5
% AT3G01440     subunit of lumenal location 3
% AT2G39470     subunit of lumenal location 1
% AT5G13120     subunit of lumenal location 5
% AT4G39710     subunit of lumenal location 4
% AT1G14150     subunit of lumenal location 2
model = addMultipleMetabolites(model,...
    {'NDHox[h]', 'NDHrd[h]'},...
    'metNames', {'NDH oxidized', 'NDH reduced'},...
    'metFormulas', {'',''},...
    'metCharges', [0 0]);
model = addReaction(model, 'NDH1_h',...
    'reactionName', 'NADH dehydrogenase-like (NDH) complex',...
    'reactionFormula', '2 H[h] + Fdrd[h] + NDHox[h]   ->   2 H[l] + Fdox[h] + NDHrd[h]',...
    'geneRule', ['ATCG01100 and ATCG00890 and ATCG00440 and ATCG01050 and '...
    'ATCG01070 and ATCG01010 and ATCG01080 and ATCG01110 and ATCG01090 and '...
    'ATCG00420 and ATCG00430 and AT1G70760 and AT4G37925 and AT5G58260 and '...
    'AT1G74880 and AT1G15980 and AT3G16250 and AT1G18730 and AT5G43750 and '...
    'AT3G01440 and AT2G39470 and AT5G13120 and AT4G39710 and AT1G14150 and '...
    'AT5G21430 and AT4G23890 and AT4G09350 and ATCG01250']);
model.rxnNotes(findRxnIDs(model, 'NDH1_h')) = {'Reference: 10.1007/s11120-016-0227-0'};

model = addReaction(model, 'NDH2_h',...
    'reactionName', 'NADH dehydrogenase-like (NDH) complex',...
    'reactionFormula', 'PQ[h] + 4 H[h] + 2 NDHrd[h]   ->   PQH2[h] + 2 NDHox[h]',...
    'geneRule', ['ATCG01100 and ATCG00890 and ATCG00440 and ATCG01050 and '...
    'ATCG01070 and ATCG01010 and ATCG01080 and ATCG01110 and ATCG01090 and '...
    'ATCG00420 and ATCG00430 and AT1G70760 and AT4G37925 and AT5G58260 and '...
    'AT1G74880 and AT1G15980 and AT3G16250 and AT1G18730 and AT5G43750 and '...
    'AT3G01440 and AT2G39470 and AT5G13120 and AT4G39710 and AT1G14150 and '...
    'AT5G21430 and AT4G23890 and AT4G09350 and ATCG01250']);
model.rxnNotes(findRxnIDs(model, 'NDH2_h')) = {'Reference: 10.1007/s11120-016-0227-0'};

% ==> The addition of NDH1_h and NDH2_h reactions increases predicted
% relative growth rate to 0.0058 h^-1

% split cytb6f complex reaction
model = removeRxns(model, 'Cytb6f_h', 'metFlag', false);
model = addMetabolite(model, 'PQstar[h]',...
    'metName', 'Plastoquinone radical',...
    'metFormula', 'C13H16O2',...
    'Charge', 0);
model = addReaction(model, 'Cytb6f1_h',...
    'reactionName', 'cytochrome b6f complex',...
    'reactionFormula', 'PQH2[h] + PCox[h]   ->   2 H[l] + PCrd[h] + PQstar[h]',...
    'geneRule', ['ATCG00540 and ATCG00720 and AT4G03280 and ATCG00730 and ' ...
    'ATCG00600 and ATCG00590 and AT2G26500 and ATCG00210']);
model = addReaction(model, 'Cytb6f2_h',...
    'reactionName', 'cytochrome b6f complex',...
    'reactionFormula', '2 H[h] + PCox[h] + PQstar[h]   ->   PQ[h] + 2 H[l] + PCrd[h]',...
    'geneRule', ['ATCG00540 and ATCG00720 and AT4G03280 and ATCG00730 and ' ...
    'ATCG00600 and ATCG00590 and AT2G26500 and ATCG00210']);

% add alternative oxidase reactions to the chloroplast and mitochondria
model = addReaction(model, 'AOX1A_m',...
    'reactionName', 'Ubiquinol oxidase 1a',...
    'reactionFormula', '2 QH2[m] + O2[m]   ->   2 H2O[m] + 2 Q[m]',...
    'geneRule', 'AT3G22370 or AT3G22360 or AT3G27620 or AT5G64210 or AT1G32350');
model = addReaction(model, 'AOX4_h',...
    'reactionName', 'Alternative NAD(P)H-ubiquinone oxidoreductase C1',...
    'reactionFormula', '2 PQH2[h] + O2[h]   ->   2 PQ[h] + 2 H2O[h]',...
    'geneRule', 'AT4G22260');

% add missing chloroplast transport reactions
model = addMultipleMetabolites(model,...
    {'Na[c]', 'Na[h]'},...
    'metNames', {'Sodium', 'Sodium'},...
    'metFormulas', {'Na','Na'},...
    'metCharges', [1 1]);

model = addReaction(model, 'Tr_Asp_OAA_h',...
    'reactionName', 'Asp/OAA transporter',...
    'reactionFormula', 'OAA[c] + Asp[h]   <=>   OAA[h] + Asp[c]',...
    'geneRule', 'AT5G64280');
model.rxnNotes(findRxnIDs(model, 'Tr_Asp_OAA_h')) = {'Reference: 10.1093/mp/ssp108'};

% ==> The addition of the Tr_Asp_OAA_h reaction increases predicted
% relative growth rate to 0.0059 h^-1

model = addReaction(model, 'Tr_DIT1_OAA_h',...
    'reactionName', 'Dicarboxylate transporter',...
    'reactionFormula', 'OAA[c] + Mal[h]   <=>   Mal[c] + OAA[h]',...
    'geneRule', 'AT5G12860');
model.rxnNotes(findRxnIDs(model, 'Tr_DIT1_OAA_h')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_H_Na_h',...
    'reactionName', 'H/Na translocation',...
    'reactionFormula', 'H[c] + Na[h]   <=>   H[h] + Na[c]',...
    'geneRule', 'AT3G19490');
model.rxnNotes(findRxnIDs(model, 'Tr_H_Na_h')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_Pi_h',...
    'reactionName', 'Pi/H translocation',...
    'reactionFormula', 'Pi[h] + H[c]   <=>   H[h] + Pi[c]',...
    'geneRule', 'AT3G26570 or AT2G38060 or AT4G00370 or AT5G20380 or AT3G46980');
model.rxnNotes(findRxnIDs(model, 'Tr_Pi_h')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_Pyr_H_h',...
    'reactionName', 'Pyr/H translocator',...
    'reactionFormula', 'H[c] + Pyr[c]   <=>   H[h] + Pyr[h]',...
    'geneRule', '');
model.rxnNotes(findRxnIDs(model, 'Tr_Pyr_H_h')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_Pyr_Mal_h',...
    'reactionName', 'Mal/Pyr translocator',...
    'reactionFormula', 'Mal[c] + Pyr[h]   <=>   Pyr[c] + Mal[h]',...
    'geneRule', '');
model.rxnNotes(findRxnIDs(model, 'Tr_Pyr_Mal_h')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_Pyr_Na_h',...
    'reactionName', 'Pyr/Na translocator',...
    'reactionFormula', 'Na[c] + Pyr[c]   <=>   Na[h] + Pyr[h]',...
    'geneRule', 'AT2G26900');
model.rxnNotes(findRxnIDs(model, 'Tr_Pyr_Na_h')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_THF_h',...
    'reactionName', 'folate transporter',...
    'reactionFormula', 'THF[c]   <=>   H[c] + THF[h]',...
    'geneRule', 'AT5G66380 or AT2G32040');
model.rxnNotes(findRxnIDs(model, 'Tr_THF_h')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_Asp_Glu_m',...
    'reactionName', 'Glu/Asp translocator',...
    'reactionFormula', 'Glu[c] + Asp[m]   <=>   Glu[m] + Asp[c]',...
    'geneRule', '');
model.rxnNotes(findRxnIDs(model, 'Tr_Asp_Glu_m')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_Asp_m',...
    'reactionName', 'Asp transport',...
    'reactionFormula', 'Asp[m]   <=>   Asp[c]',...
    'geneRule', '');
model.rxnNotes(findRxnIDs(model, 'Tr_Asp_m')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_Cit_iCit_m',...
    'reactionName', 'Cit/iCit translocator',...
    'reactionFormula', 'Cit[m] + iCit[c]   <=>   iCit[m] + Cit[c]',...
    'geneRule', '');
model.rxnNotes(findRxnIDs(model, 'Tr_Cit_iCit_m')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_DIC4_m',...
    'reactionName', 'Dicarboxylate carrier',...
    'reactionFormula', 'OAA[c] + Pi[m]   <=>   Pi[c] + OAA[m]',...
    'geneRule', 'AT2G22500 or AT4G24570 or AT5G09470');
model.rxnNotes(findRxnIDs(model, 'Tr_DIC4_m')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_KG_Mal_m',...
    'reactionName', 'KG/Mal translocator',...
    'reactionFormula', 'Mal[c] + KG[m]   <=>   Mal[m] + KG[c]',...
    'geneRule', '');
model.rxnNotes(findRxnIDs(model, 'Tr_KG_Mal_m')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_PIC_m',...
    'reactionName', 'Pi/H translocation',...
    'reactionFormula', 'Pi[c] + H[m]   <=>   H[c] + Pi[m]',...
    'geneRule', 'AT5G14040 or AT3G48850');
model.rxnNotes(findRxnIDs(model, 'Tr_PIC_m')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_DTC5_m',...
    'reactionName', 'Dicarboxylate transporter',...
    'reactionFormula', 'OAA[c] + Mal[m]   <=>   Mal[c] + OAA[m]',...
    'geneRule', 'AT5G19760');
model.rxnNotes(findRxnIDs(model, 'Tr_DTC5_m')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_UCP_m',...
    'reactionName', 'mitochondrial uncoupling protein (proton translocating)',...
    'reactionFormula', 'H[m]   <=>   H[c]',...
    'geneRule', 'AT3G54110 or AT5G58970 or AT5G19760');
model.rxnNotes(findRxnIDs(model, 'Tr_UCP_m')) = {'Reference: 10.1093/mp/ssp108'};


% add missing peroxisome transport reactions
model = addReaction(model, 'Tr_PXN3_p',...
    'reactionName', 'nicotinamide adenine dinucleotide carrier',...
    'reactionFormula', 'NAD[c] + NADH[p]   <=>   NADH[c] + NAD[p]',...
    'geneRule', 'AT2G39970');
model.rxnNotes(findRxnIDs(model, 'Tr_PXN3_p')) = {'Reference: 10.1093/mp/ssp108'};

model = addMultipleMetabolites(model,...
    {'SCA[p]', 'iCit[p]'},...
    'metNames', {'Succinate', 'Isocitrate'},...
    'metFormulas', {'C4H4O4','C6H5O7'},...
    'metCharges', [-2 -3]);
model = addReaction(model, 'Tr_SCA_p',...
    'reactionName', 'succinate transport',...
    'reactionFormula', 'SCA[c]   <=>   SCA[p]',...
    'geneRule', '');
model.rxnNotes(findRxnIDs(model, 'Tr_SCA_p')) = {'Reference: 10.1093/mp/ssp108'};

model = addReaction(model, 'Tr_iCit_p',...
    'reactionName', 'isocitrate transport',...
    'reactionFormula', 'iCit[c]   <=>   iCit[p]',...
    'geneRule', '');
model.rxnNotes(findRxnIDs(model, 'Tr_iCit_p')) = {'Reference: 10.1093/mp/ssp108'};

% add H+ sinks/source reaction added for each compartment
model = removeRxns(model, 'Si_H');
model = addReaction(model, 'Si_H_c',...
    'reactionName', 'Proton sink/source for charge balancing of im-/export',...
    'reactionFormula', '<=> H[c]',...
    'geneRule', '');
model = addReaction(model, 'Si_H_h',...
    'reactionName', 'Proton sink/source for charge balancing of im-/export',...
    'reactionFormula', '<=> H[h]',...
    'geneRule', '');
model = addReaction(model, 'Si_H_m',...
    'reactionName', 'Proton sink/source for charge balancing of im-/export',...
    'reactionFormula', '<=> H[m]',...
    'geneRule', '');
model = addReaction(model, 'Si_H_p',...
    'reactionName', 'Proton sink/source for charge balancing of im-/export',...
    'reactionFormula', '<=> H[p]',...
    'geneRule', '');

% update H+/ATP ratio for ATPases to 3 : 1 (chloroplast) and 4:1 (mitochondria)
model = addReaction(model, 'ATPase_h',...
    'reactionName', 'ATPase',...
    'reactionFormula', '4 H[l] + ADP[h] + Pi[h]   <=>   H2O[h] + 3 H[h] + ATP[h]',...
    'geneRule', ['ATCG00120 and ATCG00480 and ( AT4G04640 or AT1G15700 ) '...
    'and AT4G09650 and ATCG00470 and ATCG00150 and ATCG00130 and ATCG00140']);
model.rxnNotes(findRxnIDs(model, 'ATPase_h')) = {'Reference: 10.1073/pnas.1202799109'};

% The update of ATPase_h stoichiometry resulted in an increased predicted
% relative growth rate of 0.0062 h^-1

model = addReaction(model, 'cplx5_m',...
    'reactionName', 'ATP synthase',...
    'reactionFormula', 'ADP[m] + Pi[m] + 3 H[i]   <=>   2 H[m] + H2O[m] + ATP[m]',...
    'geneRule', ['ATMG01190 and ( AT5G08670 or AT5G08690 or AT5G08680 ) and '...
    'AT2G33040 and ( AT5G13450 or AT5G47030 ) and AT1G51650 and ( ATMG00410 '...
    'or ATMG01170 ) and ( ATMG00640 or ATMG00480 ) and ( ATMG01080 or AT2G07671 ) and AT3G52300']);
model.rxnNotes(findRxnIDs(model, 'cplx5_m')) = {'Reference: 10.1016/j.bbabio.2016.02.019'};

% add direct conversion of alanine to aspartate in cytosol, chloroplast,
% and mitochondria
model = addReaction(model, 'AspAT2_c',...
    'reactionName', 'Asp aminotransferase',...
    'reactionFormula', 'OAA[c] + Ala[c]   <=>   Pyr[c] + Asp[c]',...
    'geneRule', 'AT5G51690 or AT1G62960 or AT1G62800 or AT5G19550 or AT5G11520 or AT2G22250');
model.rxnNotes(findRxnIDs(model, 'AspAT2_c')) = {'Reference: 10.1046/j.1365-313X.1995.07010061.x, 10.1016/j.abb.2012.06.006'};

model = addReaction(model, 'AspAT2_h',...
    'reactionName', 'Asp aminotransferase',...
    'reactionFormula', 'OAA[h] + Ala[h]   <=>   Pyr[h] + Asp[h]',...
    'geneRule', 'AT2G22250 or AT4G31990 or AT5G11520');
model.rxnNotes(findRxnIDs(model, 'AspAT2_h')) = {'Reference: 10.1046/j.1365-313X.1995.07010061.x, 10.1016/j.abb.2012.06.006'};

model = addReaction(model, 'AspAT2_m',...
    'reactionName', 'Asp aminotransferase',...
    'reactionFormula', 'OAA[m] + Ala[m]   <=>   Pyr[m] + Asp[m]',...
    'geneRule', 'AT2G30970 or AT4G31990');
model.rxnNotes(findRxnIDs(model, 'AspAT2_m')) = {'Reference: 10.1046/j.1365-313X.1995.07010061.x, 10.1016/j.abb.2012.06.006'};

model = addReaction(model, 'AspAT2_p',...
    'reactionName', 'Asp aminotransferase',...
    'reactionFormula', 'OAA[p] + Ala[p]   <=>   Pyr[p] + Asp[p]',...
    'geneRule', 'AT5G11520');
model.rxnNotes(findRxnIDs(model, 'AspAT2_p')) = {'Reference: 10.1046/j.1365-313X.1995.07010061.x, 10.1016/j.abb.2012.06.006'};

% additional changes that were introduced in this study (not mentioned in
% the table with the other changes)

% move chorismate mutase from cytosol to chloroplast
model = changeGeneAssociation(model, 'CHRM_c', 'AT5G10870');
% add mitochondrial chorismate mutase
model = addReaction(model, 'CHRM_h',...
    'reactionName', 'CHR mutase',...
    'reactionFormula', 'CHR[h]   ->   PRE[h]',...
    'geneRule', 'AT3G29200 or AT1G69370');
% combine KAR1_h and KAR2_h into KAT12_h
model = addReaction(model, 'KARI12_h',...
    'reactionName', 'Ketol-acid reductoisomerase',...
    'reactionFormula', 'H[h] + NADPH[h] + AHB[h]   ->   NADP[h] + DHMP[h]',...
    'geneRule', 'AT3G58610');
% combine KAR3_h and KAR4_h into KAT34_h
model = addReaction(model, 'KARI34_h',...
    'reactionName', 'Ketol-acid reductoisomerase',...
    'reactionFormula', 'H[h] + NADPH[h] + AL[h]   ->   NADP[h] + DHMB[h]',...
    'geneRule', 'AT3G58610');
model = removeRxns(model, {'KARI1_h', 'KARI2_h', 'KARI3_h', 'KARI4_h'});

% move methionine adenosyltransferase reaction from chloroplast to cytosol
model = addReaction(model, 'MetAdT_c',...
    'reactionName', 'Met adenosyltransferase',...
    'reactionFormula', 'ATP[c] + H2O[c] + Met[c]   ->   H[c] + Pi[c] + PPi[c] + aMet[c]',...
    'geneRule', 'AT1G02500 or AT2G36880 or AT4G01850 or AT3G17390');
model = removeRxns(model, 'MetAdT_h');

% add mitochondrial NADH dehydrogenase
model = addReaction(model, 'NDA2_1_m',...
    'reactionName', 'NADH dehydrogenase',...
    'reactionFormula', 'H[m] + NADH[m] + Q[m]   ->   NAD[m] + QH2[m]',...
    'geneRule', 'AT1G07180 or AT2G29990 or AT4G28220 or AT4G05020 or AT4G21490 or AT2G20800 or AT5G08740');
model = addReaction(model, 'NDA2_2_m',...
    'reactionName', 'NADH dehydrogenase',...
    'reactionFormula', 'H[m] + Q[m] + NADPH[m]   ->   QH2[m] + NADP[m]',...
    'geneRule', 'AT1G07180 or AT2G29990 or AT4G28220 or AT4G05020 or AT4G21490 or AT2G20800 or AT5G08740');

% add PGRL1 complex
model = addMultipleMetabolites(model,...
    {'PGR5_PGRL1ox[h]', 'PGR5_PGRL1rd[h]'},...
    'metNames', {'PGR5 PGRL1 complex oxidized', 'PGR5 PGRL1 complex reduced'},...
    'metFormulas', {'',''},...
    'metCharges', [1 -1]);
model = addReaction(model, 'PGR5PGRL11_h',...
    'reactionName', 'proton gradient regulation 5 (PGR5)/PGR5-like photosynthetic phenotype 1 (PGRL1) complex',...
    'reactionFormula', 'Fdrd[h] + PGR5_PGRL1ox[h]   ->   Fdox[h] + PGR5_PGRL1rd[h]',...
    'geneRule', 'AT2G05620 and AT4G22890 and AT4G11960');
model = addReaction(model, 'PGR5PGRL12_h',...
    'reactionName', 'proton gradient regulation 5 (PGR5)/PGR5-like photosynthetic phenotype 1 (PGRL1) complex',...
    'reactionFormula', 'PQ[h] + 4 H[h] + 2 PGR5_PGRL1rd[h]   ->   PQH2[h] + 2 PGR5_PGRL1ox[h]',...
    'geneRule', 'AT2G05620 and AT4G22890 and AT4G11960');

% move isocitrate lyase from cytosol to peroxisome
model = addReaction(model, 'iCitL_p',...
    'reactionName', 'isocitrate lyase',...
    'reactionFormula', 'iCit[p]   ->   GLX[p] + SCA[p]',...
    'geneRule', 'AT3G21720');
model = removeRxns(model, 'iCitL_c');

%% additional changes (Wendering)
% annotated as NAD-dependent
model = removeRxns(model, 'GluSNADP_h');
model.rxnNotes(findRxnIDs(model, 'GluSNAD_h')) = {'Reference: 10.1046/j.1365-313X.2002.01218.x; KEGG: R00093'};
% update GPR for mitochondrial Alanine transaminase reaction
% reference: https://doi.org/10.1002/pld3.171
model = changeGeneAssociation(model, 'AlaTA_m', 'AT1G72330 or AT3G08860 or AT1G17290');
model.rxnNotes(findRxnIDs(model, 'AlaTA_m')) = {'Reference: 10.1002/pld3.171; KEGG: R00258'};

% update GPR of malate dehydrogenase reactions that were not updated by
% Blätke and Bräutigam (2019)
model = changeGeneAssociation(model, 'MalDH1_c', 'AT5G43330 or AT5G56720 or AT1G04410');
model = changeGeneAssociation(model, 'MalDH1_m', 'AT1G53240 or AT3G15020');
model = changeGeneAssociation(model, 'MalDH1_h', 'AT3G47520 or AT5G09660');

% update GPR for PGAM reactions
% (AT5G04120 is phosposerine phosphatase)
model = changeGeneAssociation(model, 'PGAM_c', 'AT3G50520 or AT1G09780 or AT3G08590');
% (AT1G09780 localized to cytoplasm)
model = changeGeneAssociation(model, 'PGAM_h', 'AT1G22170 or AT1G78050');

% Function: 
%   https://doi.org/10.1074/jbc.M111.330621
% Localization:
%   interaction with cytosolic proteins: https://string-db.org/network/3702.AT5G04120.1
%   GO cellular compartment: cytoplasm 

%% Scale coefficients in biomass reaction to sum up to 1 g/gDW

% get index and original values
bio_idx = findRxnIDs(model,'Bio_opt');
bio_subs_idx = any(model.S(:,bio_idx)~=0,2);
bio_coeff = -model.S(bio_subs_idx,bio_idx);
mol_mass = getMolecularMass(model.metFormulas(bio_subs_idx)) / 1e6; % g/umol

bio_weights = bio_coeff .* mol_mass;
sum_biomass = sum(bio_weights);

% rescale biomass to 1 g/gDW
% GAM cannot be excluded because no proper GAM can be found in the form of
% ATP + H2O -> ADP + Pi
new_weights = bio_weights / sum_biomass;
new__subs_coeffs = new_weights ./ mol_mass;

% also scale product side
bio_prod_idx = model.S(:,bio_idx) > 0;
bio_prod_coeff = model.S(bio_prod_idx,bio_idx);
mol_mass_prod = getMolecularMass(model.metFormulas(bio_prod_idx)) / 1e6;
bio_prod_mass = bio_prod_coeff .* mol_mass_prod;

new_weights = bio_prod_mass / sum_biomass;

new_prod_coeff = new_weights ./ mol_mass_prod;

model.S(bio_prod_idx,bio_idx) = new_prod_coeff;
model.S(bio_subs_idx,bio_idx) = -new__subs_coeffs;

% ==> after correction of biomass reaction, the predicted relative growth
% rate decreases to 0.0036 h^-1

%% Fix GPR rules
% correct rules: some complex stoichiometries were interpreted as genes and
% added to the rules without logical operators
problematic_genes = find(~contains(model.genes,'AT'));
for i = 1:numel(problematic_genes)
    model.rules = strrep(model.rules,['x(' num2str(problematic_genes(i)) ')'],'');
end
model.rules = strrep(model.rules,'  ',' ');

model = changeGeneAssociation(model, 'cplx1_m',...
    ['( ATMG01275 or ATMG01120 or ATMG00516 ) and ( ATMG00285 or ATMG01320 ) '...
    'and ATMG00990 and ( ATMG00580 or ATMG00650 ) and ( ATMG00513 or '...
    'ATMG00665 or ATMG00060 ) and ATMG00270 and ATMG00510 and ATMG00070 and '...
    'AT5G37510 and AT5G11770 and ( AT1G79010 or AT1G16700 ) and AT5G08530 and AT4G02580']);
model = changeGeneAssociation(model, 'ATPCitL_c', ...
    '( AT1G10670 or AT1G60810 or AT1G09430 ) and ( AT3G06650 or AT5G49460 )');
model = changeGeneAssociation(model, 'SGAT_h', 'AT2G13360');
model = changeGeneAssociation(model, 'HSerDHNADP_h',...
    'AT1G31230 or AT4G19710 or ( AT1G31230 and AT4G19710)');
model = changeGeneAssociation(model, 'HSerDHNAD_h',...
    'AT1G31230 or AT4G19710 or ( AT1G31230 and AT4G19710)');
model = changeGeneAssociation(model, 'GAPDH1_h',...
    'AT3G26650 or AT1G12900 or ( AT3G26650 and AT1G42970 ) or ( AT1G12900 and AT1G42970 )');
model = changeGeneAssociation(model, 'UDPR_c',...
    'AT2G21790 and ( AT3G23580 or AT3G27060 )');
model = changeGeneAssociation(model, 'RBC_h',...
    'ATCG00490 and ( AT5G38430 or AT5G38420 or AT1G67090 or AT5G38410 )');
model = changeGeneAssociation(model, 'PyrK_h',...
    'AT3G22960 and ( AT5G52920 or AT1G32440 )');
model = changeGeneAssociation(model, 'PyrDH1_m',...
    'AT1G59900 and AT5G50850');
model = changeGeneAssociation(model, 'PyrDH2_m',...
    'AT1G59900 and AT5G50850');
model = changeGeneAssociation(model, 'RBO_h',...
    'ATCG00490 and ( AT5G38430 or AT5G38420 or AT1G67090 or AT5G38410 )');
model = changeGeneAssociation(model, 'ACoAC_h',...
    '( AT5G16390 or AT5G15530 ) and AT5G35360 and AT2G38040 and ATCG00500');
model = changeGeneAssociation(model, 'Asnase_c', 'AT5G08100 and AT3G16150');
model = changeGeneAssociation(model, 'ANTS_h',...
    'AT1G24807 and ( AT3G55870 or AT5G05730 or AT2G29690 )');
model = changeGeneAssociation(model, 'ADPR_c',...
    'AT2G21790 and ( AT3G23580 or AT3G27060 )');
model = changeGeneAssociation(model,'CDPR_c',...
    'AT2G21790 and ( AT3G23580 or AT3G27060 )');
model = changeGeneAssociation(model,'GDPR_c',...
    'AT2G21790 and ( AT3G23580 or AT3G27060 )');
model = changeGeneAssociation(model,'UDPR_c',...
    'AT2G21790 and ( AT3G23580 or AT3G27060 )');
model = changeGeneAssociation(model,'PSII_h',...
    ['ATCG00020 and ATCG00680 and ATCG00280 and ATCG00270 and ATCG00580 '...
    'and ATCG00570 and ATCG00710 and ATCG00080 and ATCG00550 and ATCG00070 '...
    'and ATCG00560 and ATCG00220 and ATCG00700 and ( AT5G66570 or AT3G50820 ) '...
    'and AT1G06680 and ( AT4G21280 or AT4G05180 ) and AT1G79040 and AT1G44575 '...
    'and ATCG00690 and AT3G21055 and AT2G30570 and AT2G06520 and AT1G67740 and ATCG00300']);

model.rules = strtrim(model.rules);

model = removeGenesFromModel(model,...
    [model.genes(problematic_genes); {'ORAT5G49460'}]);

clear problematic_genes i

%% Remove protein IDs
model = rmfield(model, 'proteins');

%% Add gene names and UniProt IDs

% write current gene IDs to text file
writetable(cell2table(model.genes),...
    fullfile('AraCore_v2_0', 'aracore_gene_ids.txt'),...
    'WriteVariableNames', false);

% read mapped gene names (via UniProt)
gene_name_tab = readtable(fullfile('AraCore_v2_0/aracore_gene_names_uniprot_20230302.tsv'),...
    'ReadVariableNames', true,...
    'FileType', 'text');

model.geneUniprotID = repmat({''}, size(model.genes));
% find all reviewed entries
rev_idx = ismember(gene_name_tab.Reviewed, 'reviewed');
for i = 1:numel(model.genes)
    match_idx = ismember(gene_name_tab.From, model.genes{i});
    if sum(match_idx) > 1
        if any(rev_idx(match_idx))
            match_idx = find(match_idx&rev_idx,1);
        else
            match_idx = find(match_idx,1);
        end
    end
    
    gene_id_split = strsplit(gene_name_tab.GeneNames{match_idx});
    model.geneNames{i} = gene_id_split{1};
    model.geneUniprotID{i} = gene_name_tab.Entry{match_idx};
end

clear gene_id_split match_idx rev_idx i gene_name_tab

model = creategrRulesField(model);

%% save updated AraCore model (v2.0)
model.modelName = 'ArabidopsisCoreModel';
model.modelID = 'AraCore_v2.0';
% matlab workspace
writeCbModel(model,...
    'format', 'mat',...
    'fileName', fullfile('AraCore_v2_0', 'AraCore_v2_0'),...
    'compSymbols', model.comps,...
    'compNames', model.compNames);
% sbml format
writeCbModel(model,...
    'format', 'sbml',...
    'fileName', fullfile('AraCore_v2_0', 'AraCore_v2_0'),...
    'compSymbols', model.comps,...
    'compNames', model.compNames);
% Excel format
writeCbModel(model,...
    'format', 'xls',...
    'fileName', fullfile('AraCore_v2_0', 'AraCore_v2_0'),...
    'compSymbols', model.comps,...
    'compNames', model.compNames);

%% Updates for metabolite names
model = readCbModel(fullfile('AraCore_v2_0', 'AraCore_v2_0.mat'));

% update metabolite names to faciliate matching to BRENDA metabolite names
model.metNames(ismember(model.metNames,'Ribulose 1,5-bisphosphate')) = ...
    {'D-ribulose 1,5-bisphosphate'};
model.metNames(ismember(model.metNames,'Histidinol phosphate')) = ...
    {'L-histidinol 1-phosphate'};
model.metNames(ismember(model.metNames,'3-Isopropylmalate')) = ...
    {'(2R,3S)-3-isopropylmalate'};
model.metNames(ismember(model.metNames,'Aspartate 4-semialdehyde')) = ...
    {'L-Aspartate 4-semialdehyde'};
model.metNames(ismember(model.metNames,'Fructose 1,6-bisphosphate')) = ...
    {'D-Fructose 1,6-bisphosphate'};
model.metNames(ismember(model.metNames,'3-Phosphoglycerate')) = ...
    {'(R)-3-phosphoglycerate'};
model.metNames(ismember(model.metNames,'Glucose 6-phosphate')) = ...
    {'D-Glucose 6-phosphate'};
model.metNames(ismember(model.metNames,'Glucose 1-phosphate')) = ...
    {'D-Glucose 1-phosphate'};
model.metNames(ismember(model.metNames,'Glucose')) = ...
    {'D-Glucose'};
model.metNames(ismember(model.metNames,'Fructose')) = ...
    {'D-Fructose'};
model.metNames(ismember(model.metNames,'Fructose 6-phosphate')) = ...
    {'D-Fructose 6-phosphate'};
model.metNames(ismember(model.metNames,'Fructose 2,6-bisphosphate')) = ...
    {'D-Fructose 2,6-bisphosphate'};
model.metNames(ismember(model.metNames,'Nicotinamide adenine dinucleotide')) = ...
    {'NAD+'};
model.metNames(ismember(model.metNames,'Nicotinamide adenine dinucleotide - reduced')) = ...
    {'NADH'};
model.metNames(ismember(model.metNames,'Nicotinamide adenine dinucleotide phosphate')) = ...
    {'NADP+'};
model.metNames(ismember(model.metNames,'Nicotinamide adenine dinucleotide phosphate - reduced')) = ...
    {'NADPH'};
model.metNames(ismember(model.metNames,'Ribose')) = ...
    {'D-Ribose'};
model.metNames(ismember(model.metNames,'Serine')) = ...
    {'L-Serine'};
model.metNames(ismember(model.metNames,'Glutamate')) = ...
    {'L-Glutamate'};
model.metNames(ismember(model.metNames,'Alanine')) = ...
    {'L-Alanine'};
model.metNames(ismember(model.metNames,'Glutamine')) = ...
    {'L-Glutamine'};
model.metNames(ismember(model.metNames,'Arginine')) = ...
    {'L-Arginine'};
model.metNames(ismember(model.metNames,'Aspartate')) = ...
    {'L-Aspartate'};
model.metNames(ismember(model.metNames,'Asparagine')) = ...
    {'L-Asparagine'};
model.metNames(ismember(model.metNames,'Cysteine')) = ...
    {'L-Cysteine'};
model.metNames(ismember(model.metNames,'Threonine')) = ...
    {'L-Threonine'};
model.metNames(ismember(model.metNames,'Histidine')) = ...
    {'L-Histidine'};
model.metNames(ismember(model.metNames,'Isoleucine')) = ...
    {'L-Isoleucine'};
model.metNames(ismember(model.metNames,'Leucine')) = ...
    {'L-Leucine'};
model.metNames(ismember(model.metNames,'Lysine')) = ...
    {'L-Lysine'};
model.metNames(ismember(model.metNames,'Homocysteine')) = ...
    {'L-Homocysteine'};
model.metNames(ismember(model.metNames,'Methionine')) = ...
    {'L-Methionine'};
model.metNames(ismember(model.metNames,'Arogenate')) = ...
    {'L-Arogenate'};
model.metNames(ismember(model.metNames,'Ornithine')) = ...
    {'L-Ornithine'};
model.metNames(ismember(model.metNames,'Proline')) = ...
    {'L-Proline'};
model.metNames(ismember(model.metNames,'Tryptophan')) = ...
    {'L-Tryptophan'};
model.metNames(ismember(model.metNames,'Valine')) = ...
    {'L-Valine'};
model.metNames(ismember(model.metNames,'Tyrosine')) = ...
    {'L-Tyrosine'};
model.metNames(ismember(model.metNames,'Inosine 5-phosphate')) = ...
    {'Inosine 5''phosphate'};
model.metNames(ismember(model.metNames,'Histidine')) = ...
    {'L-Histidine'};
model.metNames(ismember(model.metNames,'Phenylalanine')) = ...
    {'L-Phenylalanine'};
model.metNames(ismember(model.metNames,{'H2O, water'})) = ...
    {'H2O'};
model.metNames(ismember(model.metNames,{'O2, oxygen'})) = ...
    {'O2'};
model.metNames(ismember(model.metNames,{'H+, proton'})) = ...
    {'H+'};
model.metNames(ismember(model.metNames,{'CO2, carbon dioxide'})) = ...
    {'CO2'};
model.metNames(ismember(model.metNames,{'Glyceraldehyde 3-phosphate'})) = ...
    {'D-Glyceraldehyde 3-phosphate'};
model.metNames(ismember(model.metNames,{'ThPP, Thiamine pyrophosphate'})) = ...
    {'Thiamine diphosphate'};
model.metNames(ismember(model.metNames,{'alpha-Ketoglutarate, 2-Oxoglutarate'})) = ...
    {'2-Oxoglutarate'};
model.metNames(ismember(model.metNames,{'Diphosphate, Pyrophosphate'})) = ...
    {'Diphosphate'};
model.metNames(ismember(model.metNames,{'GABA, 4-Aminobutyrate'})) = ...
    {'4-Aminobutyrate'};
model.metNames(ismember(model.metNames,{'L-histidinol 1-phosphate'})) = ...
    {'L-histidinol phosphate'};
model.metNames(ismember(model.metNames,{'2-Phosphoglycerate '})) = ...
    {'2-Phosphoglycerate'};

% Add InChI-Keys to metabolites (InChI-Keys were matched via their names
% using the UniProt API with minor manual refinement)
inchiFileName = fullfile('AraCore_v2_1', 'aracore_inchikeys.tsv');
inchiTab = readtable(inchiFileName,'ReadVariableNames',true,'Delimiter','\t',...
    'FileType','text');
model.metisinchikeyID = inchiTab.inchikey;

clear inchiFileName inchiTab
% Add ModelSEED IDs (mapped via InChI-Keys with manual refinement)
modelseedTab = readtable(fullfile('AraCore_v2_1', 'aracore_met_seed_ids.tsv'),...
    'FileType', 'text');
model.metSEEDID = modelseedTab.seed_id;

% update EC numbers / add EC numbers if missing
% this was done using EC number information provided on BRENDA
ec_number_tab = readtable(fullfile('AraCore_v2_1', 'aracore_ec_numbers.tsv'),...
    'FileType', 'text');
model.rxnECNumbers = ec_number_tab.ec_number;

%% save updated AraCore model (v2.1)
model.modelName = 'ArabidopsisCoreModel';
model.modelID = 'AraCore_v2.1';
% matlab workspace
writeCbModel(model,...
    'format', 'mat',...
    'fileName', fullfile('AraCore_v2_1', 'AraCore_v2_1'),...
    'compSymbols', model.comps,...
    'compNames', model.compNames);
% sbml format
writeCbModel(model,...
    'format', 'sbml',...
    'fileName', fullfile('AraCore_v2_1', 'AraCore_v2_1'),...
    'compSymbols', model.comps,...
    'compNames', model.compNames);
% Excel format
writeCbModel(model,...
    'format', 'xls',...
    'fileName', fullfile('AraCore_v2_1', 'AraCore_v2_1'),...
    'compSymbols', model.comps,...
    'compNames', model.compNames);
