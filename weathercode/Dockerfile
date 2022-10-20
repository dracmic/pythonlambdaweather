FROM public.ecr.aws/lambda/python:3.9

RUN yum update -y && \
  yum install -y git && \
  rm -Rf /var/cache/yum && \
  /var/lang/bin/python3.9 -m pip install --upgrade pip && \
  pip install boto3 awscli requests

COPY weather.py ${LAMBDA_TASK_ROOT}
CMD [ "weather.handler" ]
