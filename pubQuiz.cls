\NeedsTeXFormat{LaTeX2e}
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
	\newlength{\Pixhelp}
	\newlength{\Pixwidth}
	\newlength{\Pixheight}
	\setlength{\Pixheight}{0.10\textheight}
	\setlength{\Pixwidth}{0.18\textwidth}

\makeatletter
% Environments
	% Rules & Instructions
		\newenvironment{PubRules}{
			\ifPubHost
				\maketitle
				\textbf{\textsc{The Rules:}}
			\begin{enumerate}
			\fi
		}{
			\ifPubHost
				\end{enumerate}
			\fi
		}
		\ifPubHost
		\else
 			 \NewEnviron{hide}{}
 			\let\PubRules\hide
  			\let\endPubRulesf\endhide
	\fi
		
	% Rounds
		\NewDocumentCommand\PubScoreBox{m o}{
			\begin{mdframed}
				#1 Score:%\\[1cm]
				\begin{center}{\huge $\nicefrac{}{\IfNoValueF{#2}{#2}}$}\end{center}
			\end{mdframed}
		}
		\NewDocumentCommand\PubHeader{m o}{
			\ifPubHost \else \clearpage
				\noindent\begin{minipage}{0.75\columnwidth} Team name:\enspace\hrulefill \end{minipage}
				\hfill \begin{minipage}{0.25\columnwidth} \PubScoreBox{#1}[#2] \end{minipage}
			\fi 
		}
		\NewDocumentCommand\PubRound{mo}{
			\PubHeader{#1}[#2]
			\ifPubHost \else \vspace{-3em} \fi
			\section*{\textbf{\underline{#1}}}
			
		}
		
	% Questions
		\NewDocumentCommand\PubQ{s O{No question given} o}{	
			% #1 Star if Question should not appear on Answer Sheet (for example, for bonus games
			% #2 Optional: Question text for host
			% #3 Optional; Answer for host
			\ifPubHost 
				\item \IfNoValueF{#2}{#2}
				\IfNoValueF{#3}{	\ifPubAnswers \\\textbf{#3} \fi	}
			\else
				\IfBooleanF{#1}{	\item \hrulefill	\par			}
			\fi
		} 
		\NewDocumentCommand\PubShortQ{s O{No question given} o}{	
			% #1 Star if Question should not appear on Answer Sheet (for example, for bonus games
			% #2 Optional: Question text for host
			% #3 Optional; Answer for host
			\ifPubHost 
				\item \IfNoValueF{#2}{#2}
				\IfNoValueF{#3}{	\ifPubAnswers	\dotfill\textbf{#3}	\fi	}
			\else
				\IfBooleanF{#1}{	\item \hrulefill	\par					}
			\fi
		} 
		\NewDocumentCommand\PubQs{m O{No question given}}{
			\foreach \i in {1,...,#1}{
				\PubQ[#2]
			}
		}
		\NewDocumentCommand\PubQPicture{m o}{
			% #1 Picture
			% #2 Answer
			\sloppy
			\begin{minipage}[c][\Pixheight+ 3.5em][b]{\Pixwidth} 
				\item[] \centering \includegraphics[keepaspectratio=true,width=\Pixwidth,height=\Pixheight]{#2} 
				\ifPubHost \\\underline{\smash{#1}}\\\else  \\[1.5em]\hrulefill \fi 
			\end{minipage}
		}
	
	% Pub Categories
		\NewDocumentCommand\PubCategoryTitleInstructions{+m +m}{
			\subsection*{\textbf{#1} \ifPubHost \hfill \fi}
			\ifPubHost \IfNoValueF{#2}{#2} \fi%
		}
		\NewDocumentCommand\PubSubcategoryTitleInstructions{+m +m}{
			\subsubsection*{\textbf{#1} \ifPubHost \hfill \fi}
			\ifPubHost \IfNoValueF{#2}{#2} \fi%
		}
		\NewDocumentCommand\PubCategoryPrint{+m}{
			\IfBlankF{#1}{
				\begin{enumerate}[topsep=0px,partopsep=0px]
					#1	
				\end{enumerate}}
		}
		\NewDocumentEnvironment{PubCategory}{s m +o +b}{
			% #1 Star if bonus category: title may be printed or hidden with printbonus/noprintbonus
			% #2 Category Name
			% #3 Optional instructions
			\IfBooleanTF{#1}{
				\ifPubBonus		\PubCategoryTitleInstructions{#2}{#3}	
				\else \ifPubHost		\PubCategoryTitleInstructions{#2}{#3}	\fi
				\fi
			}{	\PubCategoryTitleInstructions{#2}{#3}	}
		}{
			\IfBooleanTF{#1}
				{\ifPubHost \PubCategoryPrint{#4} \fi}
				{\PubCategoryPrint{#4}}
		}
		\NewDocumentEnvironment{PubCategoryColumns}{s m m +o +b}{
			% #1 Star if bonus category: title may be printed or hidden with printbonus/noprintbonus
			% #2 Category Name
			% #3 Number of Columns
			% #4 Optional instructions
			\IfBooleanTF{#1}{
				\ifPubBonus		\PubCategoryTitleInstructions{#2}{#4}	
				\else \ifPubHost		\PubCategoryTitleInstructions{#2}{#4}	\fi
				\fi
			}{	\PubCategoryTitleInstructions{#2}{#4}	}
		}{
			\IfBooleanTF{#1}{
				\ifPubHost \PubCategoryPrint{#5} \fi	
			}{
				\ifPubHost \else  \begin{multicols}{#3} \fi	
					\PubCategoryPrint{#5}
				\ifPubHost \else  \end{multicols} \fi	
			}
		}
		
		\NewDocumentCommand\PubPicturesPerLine{O{5}}{
			\pgfmathsetmacro\PubTmp{1/(1.1*#1)}
			\setlength{\Pixwidth}{\PubTmp\textwidth}
		}
		\NewDocumentEnvironment{PubCategoryPictures}{s m m +o +b}{
			% #1 Star if bonus category: title may be printed or hidden with printbonus/noprintbonus
			% #2 Category Name
			% #3 Number of Pictures per line
			% #4 Optional instructions
			\IfBooleanTF{#1}{
				\ifPubBonus		\PubCategoryTitleInstructions{#2}{#4}	
				\else \ifPubHost		\PubCategoryTitleInstructions{#2}{#4}	\fi
				\fi
			}{	\PubCategoryTitleInstructions{#2}{#4}	}
			\PubPicturesPerLine[#3]
		}{
			\PubCategoryPrint{#5}
			\PubPicturesPerLine
		}
		\NewDocumentEnvironment{PubSubcategory}{s m +o +b}{
			% #1 Star if bonus subcategory: title is hidden
			% #2 Subcategory Name
			% #3 Optional instructions
			\item[] \vspace{-1em}
			\IfBooleanTF{#1}{
				\ifPubHost		\PubSubcategoryTitleInstructions{#2}{#3}	\fi
			}{	\PubSubcategoryTitleInstructions{#2}{#3}	}
		}{
			\IfBooleanTF{#1}
				{\ifPubHost \PubCategoryPrint{#4} \fi}
				{\PubCategoryPrint{#4}} \par
		}
% Commands for simple answer sheets
		\NewDocumentCommand\PubCategorySimple{s m O{5}}{
			% Creates a category with title #2 and #3 empty questions. 
			% For creating answer sheet only
			% if starred, category will be bonus
			\IfBooleanTF{#1}
				{\begin{PubCategory}*{#2}				\end{PubCategory}}
				{\begin{PubCategory}{#2}		\PubQs{#3}	\end{PubCategory}}
		}
		\NewDocumentCommand\PubCategoryColumnsSimple{s m m o}{
			% Creates a category with title #2 and #4 empty questions, Lines in #3 columns. 
			% For creating answer sheet only
			% if starred, category will be bonus
			\IfNoValueTF{#4}{
				\pgfmathsetmacro\PubTmp{#3*5}
			}{
				\pgfmathsetmacro\PubTmp{#4}
			}
			\IfBooleanTF{#1}
				{\begin{PubCategoryColumns}*{#2}{#3}				\end{PubCategoryColumns}}
				{\begin{PubCategoryColumns}{#2}{#3}	\PubQs{\PubTmp}	\end{PubCategoryColumns}}
		}
\makeatother