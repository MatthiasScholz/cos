FROM continuumio/miniconda3
MAINTAINER Matthias Scholz <matthias.scholz@gmail.com>

ENV ENTRYKIT_VERSION=0.4.0

# Install entrykit
RUN curl -L https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz | tar zx && \
    chmod +x entrykit && \
    mv entrykit /bin/entrykit && \
    entrykit --symlink

# Install Jupyter Notebook
RUN /opt/conda/bin/conda install -c conda-forge jupyter jupyter_nbextensions_configurator jupyter_contrib_nbextensions jupyterthemes -y --quiet
RUN mkdir -p /opt/notebooks
# .Configure Jupyter Extensions Configuration Tab
RUN /opt/conda/bin/jupyter nbextensions_configurator enable
# .Enable further extensions
RUN /opt/conda/bin/jupyter nbextension enable codefolding/main
RUN /opt/conda/bin/jupyter nbextension enable code_prettify/autopep8
RUN /opt/conda/bin/jupyter nbextension enable code_prettify/code_prettify
RUN /opt/conda/bin/jupyter nbextension enable collapsible_headings/main
RUN /opt/conda/bin/jupyter nbextension enable help_panel/help_panel
RUN /opt/conda/bin/jupyter nbextension enable highlight_selected_word/main
RUN /opt/conda/bin/jupyter nbextension enable code_prettify/isort
RUN /opt/conda/bin/jupyter nbextension enable navigation-hotkeys/main
RUN /opt/conda/bin/jupyter nbextension enable notify/notify
RUN /opt/conda/bin/jupyter nbextension enable toc2/main
RUN /opt/conda/bin/jupyter nbextension enable varInspector/main
RUN /opt/conda/bin/jupyter nbextension enable comment-uncomment/main
RUN /opt/conda/bin/jupyter nbextension enable execute_time/ExecuteTime
RUN /opt/conda/bin/jupyter nbextension enable export_embedded/main
RUN /opt/conda/bin/jupyter nbextension enable hide_header/main
RUN /opt/conda/bin/jupyter nbextension enable livemdpreview/livemdpreview
RUN /opt/conda/bin/jupyter nbextension enable printview/main
RUN /opt/conda/bin/jupyter nbextension enable select_keymap/main
RUN /opt/conda/bin/jupyter nbextension enable table_beautifier/main
RUN /opt/conda/bin/jupyter nbextension enable zenmode/main
RUN /opt/conda/bin/jupyter nbextension enable cell_filter/cell_filter
RUN /opt/conda/bin/jupyter nbextension enable execution_dependencies/execution_dependencies
RUN /opt/conda/bin/jupyter nbextension enable freeze/main
RUN /opt/conda/bin/jupyter nbextension enable hide_input/main
RUN /opt/conda/bin/jupyter nbextension enable hinterland/hinterland
RUN /opt/conda/bin/jupyter nbextension enable python-markdown/main
RUN /opt/conda/bin/jupyter nbextension enable runtools/main
RUN /opt/conda/bin/jupyter nbextension enable spellchecker/main
RUN /opt/conda/bin/jupyter nbextension enable toggle_all_line_numbers/main
RUN /opt/conda/bin/jupyter nbextension enable hide_input_all/main
RUN /opt/conda/bin/jupyter nbextension enable init_cell/main
RUN /opt/conda/bin/jupyter nbextension enable move_selected_cells/main
RUN /opt/conda/bin/jupyter nbextension enable rubberband/main
RUN /opt/conda/bin/jupyter nbextension enable scratchpad/main
RUN /opt/conda/bin/jupyter nbextension enable splitcell/splitcell
RUN /opt/conda/bin/jupyter nbextension enable tree-filter/index


# Install Python Support Libraries
RUN /opt/conda/bin/conda install -c conda-forge pint autopep8 isort -y --quiet
RUN /opt/conda/bin/conda install -c conda-forge elasticsearch pandas matplotlib -y --quiet

ENTRYPOINT [ \
  "switch", \
          "shell=/bin/sh", "--", \
  "/opt/conda/bin/jupyter", "notebook", "--notebook-dir=/opt/notebooks", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.base_url=/dfs/" \
]





