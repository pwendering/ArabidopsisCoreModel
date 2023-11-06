
# The Arabidopsis core model

This repository should serve as a platform to access and further develop the Arabidopsis core metabolic model. The original model was published in the following publication, included here as version 1.0:

Anne Arnold , Zoran Nikoloski, **Bottom-up Metabolic Reconstruction of Arabidopsis and Its Application to Determining the Metabolic Costs of Enzyme Production**, _Plant Physiology_, Volume 165, Issue 3, July 2014, Pages 1380–1391, [https://doi.org/10.1104/pp.114.235358](https://doi.org/10.1104/pp.114.235358)

Since its first development in 2014, several authors have updated or corrected the model for the use in their respective publication. This repository is an attempt to collect and reconcile these updates.

It follows a summary of changes that have been introduced in later model versions.


### AraCore v1.0

- original publication (Arnold & Nikoloski (2014), doi: [10.1104/pp.114.235358](https://doi.org/10.1104/pp.114.235358)

### AraCore v2.0

#### Yuan et al. (2016), doi: [10.3389/fpls.2016.00537](https://doi.org/10.3389/fpls.2016.00537)
- make aconitase (EC 4.2.1.3) and fumarase (EC 4.2.1.2) reversible

#### Blätke & Bräutigam (2019), doi: [10.7554/eLife.49305](https://doi.org/10.7554/eLife.49305)
- add NAD-dependent malate dehydrogenases in all compartments, NADP-dependent malate dehydrogenase only in chloroplast
- remove non-chloroplast reactions associated with AT5G58330 (MalDH3_c and MalDH3_m)
- add cyclic electron flow (Shikanai (2016), doi: [10.1007/s11120-016-0227-0](https://doi.org/10.1007/s11120-016-0227-0))
- split Cytochrome b6f complex reactions
- add alternative oxidase reactions in chloroplast and mitochondrion compartments with respective GPR rules
- add missing chloroplast transport reactions for Asp/OAA,  OAA/Mal, Na<sup>+</sup>/H<sup>+</sup>, P<sub>i</sub>/H<sup>+</sup>, Pyr/H<sup>+</sup>, Mal/Pyr, Pyr/Na<sup>+</sup>, and H<sup>+</sup>/THF (Linka & Weber (2010), doi: [10.1093/mp/ssp108](https://doi.org/10.1093/mp/ssp108))
- add missing mitochondrial transport reactions for Glu/Asp, Asp, Cit/iCit, OAA/P<sub>i</sub>, Mal/KG, P<sub>i</sub>/H<sup>+</sup>, OAA/Mal, and H<sup>+</sup> (Linka & Weber (2010), doi: [10.1093/mp/ssp108](https://doi.org/10.1093/mp/ssp108))
- add missing peroxisomal transport reactions for NAD/NADH, SCA, and iCit (Linka & Weber (2010), doi: [10.1093/mp/ssp108](https://doi.org/10.1093/mp/ssp108))
- add proton sink/source reactions in each compartment 
- correct H+/ATP ratio for ATPases to 3:1 (chloroplast, Petersen et al. (2012), doi: [10.1073/pnas.1202799109](https://doi.org/10.1073/pnas.1202799109) and 4:1 (mitochondria, Turina et al. (2016), doi: [10.1016/j.bbabio.2016.02.019](https://doi.org/10.1016/j.bbabio.2016.02.019))
- add Asp aminotransferase reactions in cytosol, chloroplast, and mitochondrion with respective GPR rules (Schultz & Coruzzi (1995), doi: [10.1046/j.1365-313X.1995.07010061.x](https://doi.org/10.1046/j.1365-313X.1995.07010061.x); Duff et al. (2012), doi: [10.1016/j.abb.2012.06.006](https://doi.org/10.1016/j.abb.2012.06.006)
- move chorismate mutase reaction from cytosol to chloroplast
- add mitochondrial chorismate mutase reaction
- combine KAR1_h and KAR2_h into KAT12_h, and KAR3_h and KAR4_h into KAT34_h
- move methionine adenosyltransferase reaction from chloroplast to cytosol
- add mitochondrial NADH dehydrogenase (NDA2)
- add PGRL1 complex
- move isocitrate lyase from cytosol to peroxisome

#### von Bismarck et al. [10.1038/s41467-023-42648-x](https://doi.org/10.1038/s41467-023-42648-x)
- add cytosolic HPR reaction (HPR2) (Timm et al. (2010), doi: [10.1104/pp.110.166538](https://doi.org/10.1104/pp.110.166538))
- add hydroxypyruvate transporter between peroxisome and cytosol
- remove HPR1 from gene associations of chloroplastic HPR reaction (Timm et al. (2010), doi: [10.1104/pp.110.166538](https://doi.org/10.1104/pp.110.166538)) 
- remove GGT1(AT1G23310), GGT2 (AT1G70580), and ALAAT1 (AT1G17290) from AlaTA_h GPR rule
	+ reaction is kept without GPR rule
- remove GGT1(AT1G23310) and GGT2 (AT1G70580) from GGAT_h GPR rule
	+ reaction is kept without GPR rule
- remove gene products from GlyHMT_c GPR rules, which are not localized in the cytosol and not expressed in leaves

#### miscellaneous (Wendering, unpublished)
- remove NADP-dependent Glu synthase (Lancien et al. (2002), doi: [10.1046/j.1365-313X.2002.01218.x]( https://doi.org/10.1046/j.1365-313X.2002.01218.x))
- update GPR for mitochondrial Alanine transaminase reaction (Parthasarathy et al. (2019), doi: [10.1002/pld3.171](https://doi.org/10.1002/pld3.171))
- update GPR rules of malate dehydrogenase reactions that were not updated by Blätke & Bräutigam (2019)
- update GPR for PGAM reactions (cytosolic, chloroplastic)
- scale biomass reaction coefficients, such that they sum up to 1 g/gDW
- fix GPR rules that have not been properly read from the SBML file due to encoded complex stoichiometries
- add gene names (mapped via UniProt ID mapping tool)
- add UniProt IDs (mapped via UniProt ID mapping tool)
- add grRules field

### AraCore v2.1
#### miscellaneous (Wendering, unpublished)
- update multiple metabolite names for improved mapping to BRENDA and PubChem
- add InChI-Keys using the PubChem REST API
- add ModelSEED IDs to metabolites (mapped via InChI-Keys)
- update EC numbers to current nomenclature
