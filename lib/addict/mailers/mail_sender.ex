defmodule Addict.Mailers.MailSender do
  def send_register(user_params) do
    {:ok, user_params}
  end

  def send_reset_token(email, path, _host \\ "") do
    Addict.Configs.mailer_module().send_reset_password(email, path)
  end
end
