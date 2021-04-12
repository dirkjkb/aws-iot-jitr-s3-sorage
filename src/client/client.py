from argparse import ArgumentParser, Namespace
from concurrent.futures._base import Future
from json import dumps

from awscrt.mqtt import Connection, QoS
from awscrt.io import EventLoopGroup, DefaultHostResolver, ClientBootstrap
from awsiot.mqtt_connection_builder import mtls_from_path

parser: ArgumentParser = ArgumentParser(description='Process some integers.')
parser.add_argument('--thing_name', type=str, help='Name of the AWS IOT thing')
parser.add_argument('--endpoint', type=str, help='AWS IOT Core Endpoint')
args: Namespace = parser.parse_args()

ENDPOINT: str = args.endpoint
CLIENT_ID: str = args.thing_name
PATH_TO_CERT: str = 'certificate/deviceCert.crt'
PATH_TO_KEY: str = 'certificate/deviceCert.key'
PATH_TO_ROOT: str = 'certificate/AmazonRootCA1.pem'
TOPIC: str = 'test/test-topic'

if __name__ == '__main__':
    event_loop_group: EventLoopGroup = EventLoopGroup(1)
    host_resolver: DefaultHostResolver = DefaultHostResolver(event_loop_group)
    client_bootstrap: ClientBootstrap = ClientBootstrap(event_loop_group, host_resolver)
    mqtt_connection: Connection = mtls_from_path(
        endpoint=ENDPOINT,
        client_bootstrap=client_bootstrap,
        cert_filepath=PATH_TO_CERT,
        pri_key_filepath=PATH_TO_KEY,
        ca_filepath=PATH_TO_ROOT,
        client_id=CLIENT_ID,
        clean_session=False,
        keep_alive_secs=10
    )

    print(f'Connecting to {ENDPOINT} with client ID {CLIENT_ID}')
    connect_future: Future = mqtt_connection.connect()
    connect_future.result()

    message: dict = {'message': f'Caller: {CLIENT_ID}'}
    mqtt_connection.publish(topic=TOPIC, payload=dumps(message), qos=QoS.AT_LEAST_ONCE)
    print(f'Published: {dumps(message)} to the topic: {TOPIC}')

    disconnect_future: Future = mqtt_connection.disconnect()
    disconnect_future.result()
