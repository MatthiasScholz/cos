FROM concourse/concourse

# HACK: Using one image for web and worker - putting all keys in one folder
#       This way one avoids to use a docker volume to provide the keys afterwards,
#       like it is suggested in the concourse Docker Registry documentation.
COPY keys/web    /concourse-keys
COPY keys/worker /concourse-keys

#################################################
# NOTE: The following lines can keep untouched. #
#################################################
ARG   VERSION=unknown
LABEL version=$VERSION
COPY  version /IMAGE_VERSION
