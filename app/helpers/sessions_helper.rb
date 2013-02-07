module SessionsHelper

  def generate_existing_auth_message(providers)
    account_s = providers.length == 1 ? t("sessions.create.account") : t("sessions.create.accounts")
    them_s = providers.length == 1 ? t("sessions.create.it") : t("sessions.create.them")
    @error_message = t('sessions.create.connected_social_accounts',
                       providers: providers.join(", "), account_s: account_s, them_s: them_s)
  end

  def generate_existing_auth_status(providers)
    "user_already_registered_by_#{providers.join("_")}"
  end

end
