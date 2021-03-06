library(shiny)
library(shinyFiles)
options(shiny.maxRequestSize=500*1024^2) 
# Define UI for slider demo application
shinyUI(pageWithSidebar(

  #  Application title
  headerPanel("Enrichment analysis"),

  # Sidebar with sliders that demonstrate various available options
  sidebarPanel(width=9,
    # file
		fileInput("filename", label = "File input (support tab delimited file or csv).
							Input should contain two columns - the first column contains gene names
							and the second column contains gene scores. The gene scores could be
							binary - in which 1 represents on and 0 represents off; or continuous - 
							which may be PC loadings, p values or weights. Note EASE(DAVID) only takes
							binary inputs. All genes in the first column will be used to estimate the
							background distribution."),

		# gene name input
		fileInput("genename", label = "Alternative input. It should contains only one column, which provides gene names.
							The program will generate a binary score vector which assigns 1 to genes in this file and assigns 0 to the other genes.
							This file will be ignored if the scores are provided above.
				    (support .csv,  .txt, .tab)"),					
		fileInput("allgenes", label = "(optional) If entering alternative input above, here you can input the gene universe. 
      			By default, all genes in the annotation package are considered as the 'other' genes. However, if a smaller 
      			list of genes was originally tested, you can input it here. (support .csv,  .txt, .tab)"),		      			
	
		# marker list
		fileInput("markerlist", label = "marker list \n file name (if not specified, only
							GO sets will be considered;
		support .csv,  .txt, .tab)"),
	
		column(2,
		# 
		numericInput("llsize",
		label = "lower limit for set size",
						        value = 5),
		numericInput("ulsize",
		label = "upper limit for set size",
						        value = 500),
		radioButtons("species_buttons",
		    label = "species?",
				 choices = list("human" = 1,
								   "mouse" = 2),
						         selected = 1)),								
		column(6,
		radioButtons("method_buttons",
		    label = "method to use? (For EASE(DAVID), input should be a binary vector;
			 	For allez and EACI, input could be either a binary vector or a continuous vector)",
				 choices = list("allez" = 1,
								   "EACI" = 2,
									 "EASE(DAVID)" = 3),
						         selected = 1),								
		
		radioButtons("tail_buttons",
		    label = "one-tailed test? (For EASE(DAVID), only one-tailed test is available;
			 	For allez and EACI, please use one-tailed test if inputs are absolute values)",
				 choices = list("one-tailed" = 1,
								   "two-tailed" = 2),
						         selected = 1)),
		

		column(4,
		# pval cutoff
		 numericInput("pcut",
					    label = "adjust pvalue cutoff",
							   value = 0.1),
			br(),
		# outdir
		 shinyDirButton('Outdir', 'output folder select', 'Please select a folder to store the output files'),
  	# h1(""),
		 br(),
	# export normalzied matrix
	textInput("exFileName", 
	label = "prefix of the export files", 
		        value = "output_results")),
	
												
		actionButton("Submit","Submit for processing")
),

						
  # Show a table summarizing the values entered
  mainPanel(
    h4(textOutput("print0")),
		#tableOutput("values")
		dataTableOutput("tab")
  )
))
