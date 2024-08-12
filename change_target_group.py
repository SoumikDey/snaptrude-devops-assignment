import boto3
import os
def lambda_handler(event, context):
    elbv2 = boto3.client('elbv2')

    rule_arn = os.environ['ALB_RULE_ARN'] 
    new_target_group_arn = os.environ['TARGET_GROUP_ARN'] 

    # # Check the health of the targets in the new target group [HAVE COMMENTED THIS OUT SINCE TARGETS ARE NOT DEPLOYED]
    # response = elbv2.describe_target_health(TargetGroupArn=new_target_group_arn)
    # healthy_targets = [target for target in response['TargetHealthDescriptions'] if target['TargetHealth']['State'] == 'healthy']

    # if len(healthy_targets) == 0:
    #     return {
    #         'statusCode': 400,
    #         'body': 'Cannot switch target group because there are no healthy targets'
    #     }

    # Modify the rule to use the new target group
    elbv2.modify_rule(
        RuleArn=rule_arn,
        Actions=[
            {
                'Type': 'forward',
                'TargetGroupArn': new_target_group_arn,
                'Order': 1
            },
        ]
    )

    return {
        'statusCode': 200,
        'body': 'Load balancer rule target group updated successfully'
    }