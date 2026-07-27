---
geometry: margin=1in
header-includes:
  - \usepackage{fancyhdr}
  - \usepackage{graphicx}
  - \usepackage{xcolor}
  - \usepackage{fontspec}
  - \usepackage{hyperref}
  - '\setmainfont[Path=__FONT_DIR__/, Extension=.ttf, UprightFont=*-Regular, BoldFont=*-Bold, ItalicFont=*-Italic, BoldItalicFont=*-BoldItalic]{Inter}'
  - \definecolor{navydark}{HTML}{19222C}
  - \definecolor{navyblue}{HTML}{223754}
  - \definecolor{accentred}{HTML}{F9322B}
  - \fancypagestyle{plain}{\fancyhf{}\fancyfoot[C]{\textcolor{navyblue}{\small\thepage}}\renewcommand{\headrulewidth}{0pt}}
  - \pagestyle{plain}
---

```{=latex}
% ── Letterhead header ────────────────────────────────────────────────────────
\noindent
\hbox to \textwidth{%
  \vtop{%
    \hsize=3.5in
    \noindent\raisebox{-\height}{%
      \includegraphics[width=2.8in]{__LOGO_PATH__}%
    }%
  }%
  \hfill%
  \vtop{%
    \parindent=0pt\hsize=2.8in\raggedleft
    \textcolor{navyblue}{\small
      Collective Impact Data \& Research Lab\\
      1401 21st St, Suite R\\
      Sacramento, CA 95811\\[2pt]
      \href{https://cidrlab.org}{cidrlab.org}
    }%
  }%
}
\vspace{6pt}
\noindent\textcolor{accentred}{\rule{\textwidth}{1.5pt}}
\vspace{0.3in}
```

**Date:** January 15, 2026

**To:** Dr. Edna Example\
Director of Research\
Example County Housing Authority

**From:** Dr. Samuel Sample, Research Director\
CiDR Lab

**Re:** Sample data-sharing collaboration (SYNTHETIC EXAMPLE)

\vspace{0.2in}

Dear Dr. Example,

This is a synthetic example letter used to exercise the `cidr-letterhead` skill.
All names, dates, and details here are fictional. It demonstrates the pandoc +
xelatex path: a Markdown letter with the CiDR Lab masthead, brand palette, Inter
typography (with graceful font fallback), and the affiliation footer.

The body can run for several paragraphs. Use this file as a template to draft a
real single-page letter, then build it with
`scripts/build-letter-pdf.sh examples/sample-letter.md out.pdf`.

We look forward to a productive collaboration.

\vspace{1in}

Sincerely,

\vspace{0.5in}

```{=latex}
\noindent Dr. Samuel Sample\\
Research Director\\
Collective Impact Data \& Research Lab (CiDR Lab)\\
samuel.sample@example.org \quad\textbullet\quad (555) 000-0000
```

```{=latex}
\vspace{0.4in}
\noindent\textcolor{accentred}{\rule{\textwidth}{0.5pt}}
\vspace{4pt}
\noindent\textcolor{navyblue}{\scriptsize
  Collective Impact Data \& Research Lab (CiDR Lab) \textbullet\
  \href{https://cidrlab.org}{cidrlab.org} \textbullet\
  Affiliated with UC Berkeley Eviction Research Network (\href{https://evictionresearch.net}{evictionresearch.net})
}
```
