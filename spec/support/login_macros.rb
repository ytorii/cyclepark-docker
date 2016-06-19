module LoginMacros
  def login(nickname, password)
    visit "/menu"
    within('form#login') do
      fill_in 'nickname', with: nickname
      fill_in 'password', with: password
      click_button 'ログイン'
    end
  end
end
