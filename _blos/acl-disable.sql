begin
   begin
      dbms_network_acl_admin.drop_acl (acl => 'all-network-PUBLIC.xml');
   exception
      when others
      then
         null;
   end;

   dbms_network_acl_admin.create_acl (
      acl           => 'all-network-PUBLIC.xml',
      description   => 'Network connects for all',
      principal     => 'PUBLIC',
      is_grant      => true,
      privilege     => 'connect');
   dbms_network_acl_admin.add_privilege (acl         => 'all-network-PUBLIC.xml',
                                         principal   => 'PUBLIC',
                                         is_grant    => true,
                                         privilege   => 'resolve');
   dbms_network_acl_admin.assign_acl (acl    => 'all-network-PUBLIC.xml',
                                      host   => '*');
end;
/

commit;