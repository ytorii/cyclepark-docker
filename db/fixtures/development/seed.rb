Staff.seed do |s|
  s.id = 1
  s.nickname = 'admin'
  s.password = '12345678'
  s.admin_flag = true
end 

Staffdetail.seed do |sd|
  sd.staff_id = 1
  sd.name = '鳥居'
  sd.read = 'トリイ'
  sd.address = '大阪府'
  sd.birthday = '1984-01-01'
  sd.phone_number = '072-820-1111'
  sd.cell_number = '090-1111-2222'
end
