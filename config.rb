module ConfigStuffs
  use OmniAuth::Strategies::LDAP,
      host: '165.91.222.132',
      port: 389,
      method: :plain,
      base: 'ou=People, dc=arch, dc=tamu, dc=edu',
      uid: 'sAMAccountName',
      bind_dn: 'cn= vblessing, ou=Temporary, ou=Staff, ou=Employees, ou=People, dc=arch, dc=tamu, edc=edu',
      password: '',
end
