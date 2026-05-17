import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

asg_client = boto3.client('autoscaling')
rds_client = boto3.client('rds')

ASG_NAME = os.environ['ASG_NAME']
RDS_ID   = os.environ['RDS_ID']
ACTION   = os.environ['ACTION']


def handler(event, context):
    logger.info(f"NexusCore FinOps - Accion: {ACTION}")
    if ACTION == 'stop':
        stop_resources()
    elif ACTION == 'start':
        start_resources()
    else:
        raise ValueError(f"ACTION invalida: {ACTION}")


def stop_resources():
    logger.info(f"Reduciendo ASG {ASG_NAME} a 0 instancias")
    asg_client.update_auto_scaling_group(
        AutoScalingGroupName=ASG_NAME,
        MinSize=0,
        MaxSize=0,
        DesiredCapacity=0
    )
    logger.info(f"Deteniendo RDS {RDS_ID}")
    try:
        rds_client.stop_db_instance(DBInstanceIdentifier=RDS_ID)
    except rds_client.exceptions.InvalidDBInstanceStateFault:
        logger.warning("RDS ya estaba detenida - ignorando")
    logger.info("Recursos detenidos exitosamente")


def start_resources():
    logger.info(f"Iniciando RDS {RDS_ID}")
    try:
        rds_client.start_db_instance(DBInstanceIdentifier=RDS_ID)
    except rds_client.exceptions.InvalidDBInstanceStateFault:
        logger.warning("RDS ya estaba corriendo - ignorando")
    logger.info(f"Restaurando ASG {ASG_NAME} a 1 instancia")
    asg_client.update_auto_scaling_group(
        AutoScalingGroupName=ASG_NAME,
        MinSize=0,
        MaxSize=2,
        DesiredCapacity=1
    )
    logger.info("Recursos iniciados exitosamente")