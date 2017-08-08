begin
    sys.dbms_aqadm.create_queue_table (
        queue_table          => 'TEST_RETARDEMENT'
       ,queue_payload_type   => 'MESSAGE_RETARDEMENT'
       ,compatible           => '10.0.0'
       ,sort_list            => 'ENQ_TIME'
       ,multiple_consumers   => true
       ,message_grouping     => 0
       ,secure               => false
    );
end;
/

begin
    sys.dbms_aqadm.create_queue (
        queue_name       => 'TEST_RETARDEMENT'
       ,queue_table      => 'TEST_RETARDEMENT'
       ,queue_type       => sys.dbms_aqadm.normal_queue
       ,max_retries      => 0
       ,retry_delay      => 0
       ,retention_time   => -1
    );
end;
/

declare
    l_subscriber   sys.aq$_agent;
begin
    l_subscriber   := sys.aq$_agent ('RECIPIENT', '', 0);
    dbms_aqadm.add_subscriber (queue_name => 'TEST_RETARDEMENT', l_subscriber => subscriber);
end;
/

begin
    sys.dbms_aqadm.start_queue (queue_name => 'TEST_RETARDEMENT', enqueue => true, dequeue => true);
end;
/

create or replace procedure programmer_message (
    p_msg    in varchar2
   ,p_date   in date
)
as
    enqueue_options      dbms_aq.enqueue_options_t;
    message_properties   dbms_aq.message_properties_t;
    message_handle       raw (16);
    message              message_retardement;
begin
    message_properties.delay   := (p_date - sysdate) * 24 * 60 * 60; -- Délai en secondes...

    message                    := message_retardement (sysdate, p_date, p_msg);
    dbms_aq.enqueue (
        queue_name           => 'TEST_RETARDEMENT'
       ,enqueue_options      => enqueue_options
       ,message_properties   => message_properties
       ,payload              => message
       ,msgid                => message_handle
    );
end;
/

create or replace procedure envoyer_message_cb (
    context     raw
   ,reginfo     sys.aq$_reg_info
   ,descr       sys.aq$_descriptor
   ,payload     raw
   ,payloadl    number
)
as
    dequeue_options      dbms_aq.dequeue_options_t;
    message_properties   dbms_aq.message_properties_t;
    message_handle       raw (16);
    message              message_retardement;
begin
    dequeue_options.msgid           := descr.msg_id;
    dequeue_options.consumer_name   := descr.consumer_name;
    dbms_aq.dequeue (
        queue_name           => descr.queue_name
       ,dequeue_options      => dequeue_options
       ,message_properties   => message_properties
       ,payload              => message
       ,msgid                => message_handle
    );

    utl_mail.send (
        sender       => 'bruno.lavoie@dti.ulaval.ca'
       ,recipients   => 'bruno.lavoie@dti.ulaval.ca'
       ,subject      => 'Un message programmé'
       ,message      =>    'Message: '
                        || message.message
                        || chr (10)
                        || 'Demandé le: '
                        || to_char (message.horodate_creation, 'YYYY-MM-DD HH24:MI:SS')
                        || chr (10)
                        || 'Pour envoi le: '
                        || to_char (message.horodate_publication, 'YYYY-MM-DD HH24:MI:SS')
                        || chr (10)
                        || 'Dépilé et officiellement envoyé le: '
                        || to_char (sysdate, 'YYYY-MM-DD HH24:MI:SS')
       ,mime_type    => 'text/plain; charset=utf-8'
    );

    commit;
end;
/

begin
    dbms_aqadm.add_subscriber (queue_name => 'TEST_RETARDEMENT', subscriber => sys.aq$_agent ('recipient', null, null));
end;
/

begin
    dbms_aq.register (
        sys.aq$_reg_info_list (sys.aq$_reg_info ('TEST_RETARDEMENT:RECIPIENT', dbms_aq.namespace_aq, 'plsql://envoyer_message_cb', hextoraw ('FF')))
       ,1
    );
end;
/


exec programmer_message('Bonjour les amis, ce message est «enqueued» pour un envoi immédiat.', sysdate);
commit;

exec programmer_message('Bonjour les amis, ce message est «enqueued» pour un envoi programmé 5 minutes après son ajout.', sysdate + 5/(24*60));
commit;

