\NeedsTeXFormat{LaTeX2e}[2022/07/05]
\ProvidesClass{pubQuiz}[2025/05/29 - Cynthia Rodriguez]
% Switch for Host script or answer sheet
	\RequirePackage{ifthen}
  	\RequirePackage{environ}
		\newif\ifPubHost
			\PubHostfalse
			\DeclareOption{host}{\PubHosttrue}
			\DeclareOption{nohost}{\PubHostfalse}
% Prints Answers for Hosts
		\newif\ifPubAnswers
			\PubAnswerstrue
			\DeclareOption{answers}{\PubAnswerstrue}
			\DeclareOption{noanswers}{\PubAnswersfalse}
% Prints Bonus Categories Title (and non-starred  questions) on the Answer sheet.
		\newif\ifPubBonus
			\PubBonustrue
			\DeclareOption{printbonus}{\PubBonustrue}
			\DeclareOption{noprintbonus}{\PubBonusfalse}
% Handle class and options
	\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
	\ProcessOptions\relax
	\LoadClass{article}
% Format
	\RequirePackage[margin=0.5in]{geometry}
	\RequirePackage{titlesec}
		\titleformat{\section}{\huge\filcenter}{\thesection}{}{}
		\titleformat{\subsection}{\Large\filcenter}{\thesubsection}{}{}
		\titleformat{\subsubsection}{\large}{\thesubsection}{}{}
		\titlespacing*{\section}{0cm}{1ex plus 1mm minus 1mm}{1ex plus 1mm minus 1mm}
		\titlespacing*{\subsection}{0cm}{2ex plus 1mm minus 1mm}{2ex plus 1mm minus 1mm}
	\pagestyle{empty} 
	\NewEnviron{hide}{}
% Category Set-up
	\setlength{\abovedisplayskip}{1em}
	\RequirePackage[inline]{enumitem}
		\setlist{itemsep=0.5ex}
	\RequirePackage{tikz}
	\RequirePackage{multicol}
		\setlength{\multicolsep}{0pt plus 3pt minus 3pt}
		\setlength{\columnsep}{5pt}
% Scorebox
	\RequirePackage{mdframed}
	\RequirePackage{nicefrac}
	\RequirePackage{graphicx}
	\RequirePackage{calc}
% Default Picture Settings
	\RequirePackage[export]{adjustbox}
	\newlength{\Pixhelp}
	\newlength{\Pixwidth}
	\newlength{\Pixheight}
	\setlength{\Pixheight}{0.12\textheight}
	\setlength{\Pixwidth}{0.18\textwidth}

\makeatletter
	
% Internal Commands	
	% Rounds:  Internal Commands
		\NewDocumentCommand\PubScoreBox{m o}{
		% Prints a box for the score of an event
		% #1: event name (internally, the round name)
		% #2: (Optional) max score for the round (printed as fraction denominator inside the box)
			\begin{mdframed}
				#1 Score:%
				\begin{center}{\huge $\IfNoValueTF{#2}{\phantom{\nicefrac{}{}}}{\nicefrac{}{#2}}$}\end{center}%
			\end{mdframed}%
		}
		
		\NewDocumentCommand\PubHeader{m o}{
		% Prints the top matter of a page: space for team names, round score box, and round name
		% #1: Round name
		% #2: (Optional) max score for the round (to print in the score box)
			\ifPubHost \else \clearpage%
				\noindent\begin{minipage}{0.75\columnwidth} Team name:\enspace\hrulefill \end{minipage}%
				\hfill \begin{minipage}{0.25\columnwidth} \PubScoreBox{#1}[#2] \end{minipage}%
			\fi%
		}
		
	% Categories: Internal Commands
		\NewDocumentCommand\PubCategoryTitleInstructions{m d<> +m}{
		% Prints the Category Title, in host script mode it also prints host-notes and host-instructions
		% #1: Category name
		% #2: host-notes inside < >, will be printed at the end of the category name line
		% #3: host-instructions which can be multi-lined.
			\subsection*{\textbf{#1} \ifPubHost \hfill 
				\IfNoValueTF{#2}{}{#2}\fi}
			\ifPubHost \IfNoValueF{#3}{#3} \fi%
		}
	
		\NewDocumentCommand\PubSubcategoryTitleInstructions{m d<> +m}{
		% Prints the Subcategory Title, in host script mode it also prints host-notes and host-instructions
		% #1: Subcategory name
		% #2: host-notes inside < >, will be printed at the end of the category name line
		% #3: host-instructions which can be multi-lined.
			\subsubsection*{\textbf{#1} \ifPubHost \hfill 
				\IfNoValueTF{#2}{}{#2}\fi}
			\ifPubHost \IfNoValueF{#3}{#3} \fi%
		}
	
		\NewDocumentCommand\PubCategoryPrint{+m}{
		% Receives the category environment body and writes it within an enumerate. If #1 is blank, does nothing
		% #1: body of category commands, may be multi-lined
			\IfBlankF{#1}{
			\begin{enumerate}[topsep=0px,partopsep=0px]
				#1	
			\end{enumerate}}
		}
	% Questions: Internal Commands
		\NewDocumentCommand\PubQs{m}{
		% For answer-sheet only usage, creates a group of answer lines
		% #1: number of questions
			\foreach \i in {1,...,#1}{	\PubQ	}
		}

% User Commands
	% Host matters: User commands
		\newenvironment{PubRules}{	
		% Environment to allow hosts to write the rules for their trivia.
		% Code underneath hides the section in answer sheets
			\maketitle
			\textbf{\textsc{The Rules:}}
			\begin{enumerate}
		}{	\end{enumerate}\par	}
		\ifPubHost \else
	 		\let\PubRules\hide
	  		\let\endPubRules\endhide
		\fi
		
		
		\newenvironment{PubInstructions}{	
		% Environment to allow hosts to write instruction sets and notes in the trivia document
			\vspace{3mm}
			\textbf{\textsc{Instructions:}}
			\begin{itemize}
		}{	\end{itemize}\par	}
		\ifPubHost \else
	 		\let\PubInstructions\hide
	  		\let\endPubInstructions\endhide
		\fi
		
		\NewDocumentCommand\PubRound{mo}{
		% Starts a new round
		% #1: Round name
		% #2: (Optional) Round points for the score box
			\PubHeader{#1}[#2]
			\ifPubHost \else \vspace{-3em} \fi
			\section*{\textbf{\underline{#1}}}
		}
	
	% Trivia Categories: User commands
		\NewDocumentEnvironment{PubCategory}{s d|| m d<> +o +b}{
		% Environment for Categories: prints title, host-notes and host-instructions
		% #1: Star if bonus category; title may be printed or hidden with printbonus/noprintbonus
		% #2: (Optional) Number of columns inside || 
		% #3: Category Name
		% #4: (Optional) Host-notes inside <>, printed at the end of the title-line
		% #5 (Optional) Host-instructions, can be multilined
		% #6 Body of the environment (received automatically)
			\IfBooleanTF{#1}{
				\ifPubBonus		\PubCategoryTitleInstructions{#3}<#4>{#5}	
				\else \ifPubHost		\PubCategoryTitleInstructions{#3}<#4>{#5}	\fi
				\fi
			}{	\PubCategoryTitleInstructions{#3}<#4>{#5}	}
		}{
			\IfBooleanTF{#1}
				{\ifPubHost \PubCategoryPrint{#6} \fi}
				{	\IfNoValueF{#2}{\ifPubHost \else \begin{multicols}{#2} \fi}	
						\PubCategoryPrint{#6}	
					\IfNoValueF{#2}{\ifPubHost \else \end{multicols} \fi}
				}\par
		}
		
		\NewDocumentCommand\PubCat{s d|| m O{5}}{
		% For creating answer sheets ONLY. Prints a category with number lines for answers
		% #1: Star, if it is a bonus category; title may be printed or hidden with printbonus/noprintbonus
		% #2: (Optional) Number of columns inside ||
		% #3: Category name
		% #4: (Optional) Number of questions (default value: 5)
			\IfBooleanTF{#1}
				{\begin{PubCategory}*|#2|{#3}					\end{PubCategory}}
				{\begin{PubCategory}|#2|{#3}		\PubQs{#4}	\end{PubCategory}}
		}

		
		\NewDocumentEnvironment{PubSubcategory}{s dII m d<> +o +b}{
		% Environment for Subcategories: prints title, host-notes and host-instructions
		% #1: Star if bonus;  subcategory and title are hidden
		% #2: (Optional) Number of columns inside || 
		% #3: Category Name
		% #4: (Optional) Host-notes inside <>, printed at the end of the title-line
		% #5 (Optional) Host-instructions, can be multilined
		% #6 Body of the environment (received automatically)
			\item[] \vspace{-1em}
			\IfBooleanTF{#1}{
				\ifPubHost		\PubSubcategoryTitleInstructions{#3}<#4>{#5}	\fi
			}{	\PubSubcategoryTitleInstructions{#3}<#4>{#5}	}
		}{
			\IfBooleanTF{#1}
				{\ifPubHost \PubCategoryPrint{#6} \fi}
				{	\IfNoValueF{#2}{\ifPubHost \else \begin{multicols}{#2} \fi}	
						\PubCategoryPrint{#6}	
					\IfNoValueF{#2}{\ifPubHost \else \end{multicols} \fi}
				}\par
		}

	% Trivia Questions: User commands
		\NewDocumentCommand\PubQ{s O{No question given} t. o}{	
		% Prints an answer line in the answer sheet (if star not given), and the question/answer for the host script.
		% #1 Star if Question should not appear on Answer Sheet (for example, for bonus games
		% #2 Optional: Question text for host
		% #3 Period if answer should be printed in short form (in the same line as the question in the host script)
		% #4 Optional; Answer for host
			\ifPubHost 
				\item \IfNoValueF{#2}{#2}
				\ifPubAnswers 	\IfNoValueF{#4}{\IfBooleanTF{#3}{\dotfill}{\\} \textbf{#4}} \fi 
			\else
				\IfBooleanF{#1}{	\item \hrulefill	\par			}
			\fi
		} 
		
		\NewDocumentCommand\PubQPic{m o}{
		% Prints a picture question: for hosts, only number and answer is printed, answer sheet prints picture and a line below)
		% #1: Picture file
		% #2: (Optional) Answer
			\item \ifPubHost #2 
			\else  %
				\centering
				\includegraphics[keepaspectratio=true,width=\Pixwidth,height=\Pixheight,valign=t]{#1} \\[7mm]
				\hrulefill \\
			\fi 
		}
\makeatother