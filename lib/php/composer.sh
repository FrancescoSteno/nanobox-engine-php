# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

# Packages required to install composer
composer_packages() {
  pkgs=("composer")
  echo "${pkgs[@]}"
}

# Runs composer install
composer_install() {
  if [[ -f $(nos_code_dir)/composer.json ]]; then
    if [[ ! -f $(nos_code_dir)/composer.lock ]]; then
      nos_print_warning "No 'composer.lock' file detected. This may cause a slow or failed build. To avoid this issue, commit the 'composer.lock' file to your git repo."
    fi
    (cd $(nos_code_dir); nos_run_process "composer install" "composer install --no-interaction --prefer-source")
  fi
}

composer_dir() {
  [[ ! -f $(nos_data_dir)/var/composer ]] && nos_run_process "make composer dir" "mkdir -p $(nos_data_dir)/var/composer"
  [[ ! -s ${HOME}/.composer ]] && nos_run_process "link composer dir" "ln -s $(nos_data_dir)/var/composer ${HOME}/.composer"
}

# Generate the payload to render the composer profile template
composer_profile_payload() {
  cat <<-END
{
  "data_dir": "$(nos_data_dir)"
}
END
}

# ensure ${HOME}/.composer/vendor/bin is persisted to the PATH
persist_composer_bin_to_path() {
  nos_template \
    "profile.d/composer.sh" \
    "$(nos_etc_dir)/profile.d/composer.sh" \
    "$(composer_profile_payload)"
}

copy_cached_files() {
  if [ -d $(nos_cache_dir)/composer ]; then
    rsync -a $(nos_cache_dir)/composer/ $(nos_data_dir)/var/composer
  fi
}

save_cached_files() {
  if [ -d $(nos_data_dir)/var/composer ]; then
    rsync -a --delete $(nos_data_dir)/var/composer/ $(nos_cache_dir)/composer
  fi
}
