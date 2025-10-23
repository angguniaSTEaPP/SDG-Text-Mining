# SDG Text Mining

A comprehensive R-based text mining toolkit for analysing Sustainable Development Goals (SDG) integration in National Development Plans (NDPs) and their correlation with SDG performance outcomes.

## Overview

This repository contains the complete code and methodology used in the research paper **"Assessing SDG Integration in National Development Plans and Their Outcomes: A Text Mining Approach"**. The study examines how 175 countries integrate SDGs into their national development strategies and whether this integration correlates with actual SDG performance.

## Research Objectives

This project investigates the relationship between SDG-referenced content in National Development Plans and tangible SDG outcomes across nations. By applying advanced text mining and sequence analysis techniques, the research reveals that while a weak positive correlation exists between NDP content and SDG scores, mere inclusion of SDG references does not guarantee progress, implementation effectiveness and governance quality remain the decisive factors.

## Abstract

National Development Plans (NDPs) are key policy instruments governments use to guide social transformation and promote economic growth. Examples from Zambia and Malawi show how social protection systems within NDPs can strengthen social security, while countries like South Korea, China, and Malaysia demonstrate that effective development planning can drive sustained GDP growth. Building on such success, nations are increasingly encouraged to integrate the Sustainable Development Goals (SDGs) into their NDPs to align national strategies with global objectives.

Past research has mainly assessed SDG integration in NDPs using manual methods, with limited use of computational techniques. This study advances the field by examining how SDG integration in NDPs relates to tangible outcomes. Using text mining, it correlates SDG-related terms in NDPs with SDG performance. Methods such as term frequency-inverse document frequency (TF-IDF), multidimensional sequence analysis, and hierarchical agglomerative clustering reveal a weak but positive correlation between NDP content and SDG scores.

This finding suggests that mere inclusion of SDG references does not guarantee progress; implementation effectiveness and governance quality remain decisive. Some nations achieve strong results despite limited alignment, driven by robust infrastructure, while others struggle despite well-integrated plans. Sequence and cluster analyses show that countries with similar income levels often share patterns, creating opportunities for collaboration and mutual learning. The study calls for stronger policy frameworks aligning NDPs with the SDGs and ensuring effective implementation. It also offers insights for international organisations designing context-sensitive interventions, including development aid programmes.

## Repository Structure

The analysis is organised into two main parts with additional utility functions:

### **PART I: SDG Term Analysis and NDP-SDG Alignment**

#### 1. SDG Term Identification and Correlation Analysis
- **`sdgterms.r`**: Identifies unique terms for each SDG goal using TF-IDF based on UN target and indicator documents
- **`sdgcorrelation.r`**: Analyses correlations between SDG goals based on UN documentation

#### 2. NDP Processing and Alignment Analysis
- **`translation.r`**: Converts PDF documents to text using `pdftools` and performs translation using `polyglotr` package
- **`ndpsdg.r`**: Analyses alignment of National Development Plans with the 17 Global Goals
- **`alignment.r`**: Examines alignment between NDP-SDG content and actual SDG performance scores

### **PART II: Pattern Analysis and Clustering**

#### 3. Income Group and Clustering Analysis
- **`tanglegram.r`**: Analyses correlation between clusters based on NDPs and SDG scores using dendrogram visualisation
- **`seqcluster.r`**: Performs country clustering analysis based on NDP-SDG priorities using sequence analysis

### **Additional Utility Functions**
- **`checklang.r`**: Detects and verifies languages of NDP documents
- **`backtranslation.r`**: Ensures translation quality and robustness through back-translation validation

## Methodology

This project employs sophisticated text mining techniques to extract meaningful patterns from unstructured NDP documents. The methodology prioritises domain-specific analysis over generalized approaches, making it more suitable for policy-focused research than broad large language models.

### Data Processing Pipeline

The analysis follows a comprehensive pre-processing workflow:

1. **Document Conversion**: PDF to text extraction using `pdftools`
2. **Language Processing**: Automated language detection and translation to English via `polyglotr`
3. **Text Cleaning**: Removal of URLs, HTML content, non-ASCII characters, and symbols using `textclean`
4. **Normalisation**: Lowercasing and tokenisation
5. **Feature Engineering**: Stopword removal and n-gram generation using `tidytext`
6. **Data Structuring**: Organization into analysable data frames with `tidyr`

### Core Analytical Methods

#### 1. Keyword Identification and Network Analysis
- Extracts SDG-related keywords from the SDG Global Indicators Tier Classification document
- Applies **Term Frequency-Inverse Document Frequency (TF-IDF)** to build a term base highlighting goal-specific terminology
- Conducts pairwise correlation and network analyses to map relationships between SDG goals

#### 2. NDP-SDG Alignment Analysis
- Analyses mid-term NDPs from **175 countries** across **19 languages**
- Implements back-translation techniques to ensure translation accuracy
- Calculates term frequency (TF) for each SDG goal based on identified keywords

#### 3. Performance Correlation Study
- Uses **SDG Index scores from SDR 2024** as performance benchmarks
- Analyses **144 countries** with complete data
- Performs **Pearson correlation** between NDP content and SDG outcomes
- Employs **sequence analysis** using `TraMineR` to identify country-level SDG priorities and patterns

#### 4. Clustering and Typology Analysis
- Groups countries with similar priority patterns using **Hierarchical Agglomerative Clustering (HAC)**
- Applies **multidimensional sequence analysis** to combined NDP and performance data
- Uses **Kelley-Gardner-Sutcliffe (KGS)** procedure for optimal cluster determination
- Generates tanglegrams with `dendextend` to visualise priority-outcome relationships
- Conducts **discrepancy analysis** and **typology validation** to ensure robust clustering

## Key R Packages

- `pdftools` - PDF to text conversion
- `polyglotr` - Language detection and translation
- `textclean` - Text preprocessing and cleaning
- `tidytext` - Tokenisation, stopword removal, and n-gram generation
- `tidyr` - Data frame manipulation
- `TraMineR` - Sequence analysis and dissimilarity measures
- `dendextend` - Dendrogram visualisation and tanglegram creation
- `cluster` - Hierarchical agglomerative clustering

## Data Sources

- **National Development Plans**: Mid-term NDPs from 175 UN member states (19 languages)
- **SDG Performance Data**: SDG Index scores from the Sustainable Development Report 2024
- **SDG Framework**: Global Indicators Tier Classification from UN Statistics Division

## Usage

### Running the Analysis

Execute the scripts in the following order:

**PART I:**
```r
# 1. Identify SDG terms and correlations
source("sdgterms.r")
source("sdgcorrelation.r")

# 2. Process NDPs and analyse alignment
source("translation.r")
source("ndpsdg.r")
source("alignment.r")
```

**PART II:**
```r
# 3. Perform clustering and pattern analysis
source("tanglegram.r")
source("seqcluster.r")
```

**Utilities (as needed):**
```r
source("checklang.r")
source("backtranslation.r")
```

## Key Findings

- **Weak positive correlation** between SDG references in NDPs and actual SDG performance
- **Implementation quality and governance** matter more than textual integration
- Countries with similar **income levels show comparable SDG priority patterns**
- Some nations achieve strong outcomes despite limited NDP-SDG alignment through robust infrastructure
- Others struggle despite well-integrated plans, highlighting governance challenges

## Applications

This research provides valuable insights for:

- **Policymakers** designing effective SDG-aligned national strategies
- **International organisations** developing context-sensitive development aid programs
- **Researchers** studying policy implementation effectiveness
- **Development practitioners** seeking evidence-based approaches to SDG integration

## Requirements

- R (version 4.0 or higher recommended)
- Required R packages (install via `install.packages()`):
  - pdftools
  - polyglotr
  - textclean
  - tidytext
  - tidyr
  - TraMineR
  - dendextend
  - cluster
  - [Additional packages as specified in individual scripts]

## Citation

If you use this code or methodology in your research, please cite the paper:

```
[Citation will be added when the paper is published]
```

## Acknowledgments

This research utilises data from:
- United Nations Sustainable Development Goals indicators and targets
- Sustainable Development Report 2024
- National Development Plans from 175 UN member states

---

**Note**: This repository focuses on domain-specific text mining techniques optimised for policy analysis. The simpler, specialised methods employed here prioritise interpretability and analytical depth over the generalised prediction capabilities.
