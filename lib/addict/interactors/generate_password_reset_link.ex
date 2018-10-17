defmodule Addict.Interactors.GeneratePasswordResetLink do
  alias Addict.Interactors.GetUserById

  def call(
        user_id,
        secret \\ Addict.Configs.secret_key(),
        reset_path \\ Addict.Configs.reset_password_path()
      ) do
    {reset_string, signature} = generate_tokens(user_id, secret)
    reset_path = reset_path || "/reset_password"
    {:ok, "#{reset_path}?token=#{reset_string}&signature=#{signature}"}
  end

  def generate_tokens(
        user_id,
        secret \\ Addict.Configs.secret_key()
      ) do
    {:ok, user} = GetUserById.call(user_id)
    current_time = to_string(:erlang.system_time(:seconds))
    reset_string = Base.encode16("#{current_time},#{user_id},#{user.pwd_reset_counter}")
    signature = Addict.Crypto.sign(reset_string, secret)
    {reset_string, signature}
  end
end
