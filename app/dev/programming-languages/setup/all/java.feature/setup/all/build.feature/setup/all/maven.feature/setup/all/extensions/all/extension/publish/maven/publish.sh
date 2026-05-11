lib net/rclone.sh

log_info "packaging and deploying artifacts"

_maven_build_artifacts() {
  find . -type f \( \
    -path '*/target/*.jar' -o \
    -path '*/target/*.war' -o \
    -path '*/target/*.ear' -o \
    -path '*/target/*.zip' \
    \) ! -path '*/.archived/*' ! -path '*/target/lib/*' ! -path '*/target/test-classes/*'
}

_rclone_publish_all _maven_build_artifacts

mvn clean deploy -DstagingProfileId=$conf_dev_deploy_staging_profile_id $conf_dev_publish_options $@

